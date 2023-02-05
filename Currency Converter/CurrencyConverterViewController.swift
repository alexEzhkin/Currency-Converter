//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

final class CurrencyConverterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak private var sellCurrencyPicker: UIPickerView!
    @IBOutlet weak private var recieveCurrencyPicker: UIPickerView!
    @IBOutlet weak private var currencyBalanceCollectionView: UICollectionView!
    @IBOutlet weak private var sellCurrencyTextField: UITextField!
    @IBOutlet weak private var recieveCurrencyLabel: UILabel!
    
    // MARK: - Properties
    
    let currencySymbols = Currencies.allCases.map { $0.segmentTitle }
    let currencyBalances: [String] = []
    
    var currencyPicker: [Currencies] = []
    var chosenStateOfsellCurrencyPicker = Currencies.USD.segmentTitle
    var chosenStateOfrecieveCurrencyPicker = Currencies.USD.segmentTitle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sellCurrencyPicker.delegate = self
        self.sellCurrencyPicker.dataSource = self
        self.recieveCurrencyPicker.delegate = self
        self.recieveCurrencyPicker.dataSource = self
        currencyPicker = Currencies.allCases
        
        self.currencyBalanceCollectionView.dataSource = self
        
        sellCurrencyTextField.delegate = self
        
        currencyBalanceCollectionView.register(UINib(nibName: "CurrencyBalanceCell", bundle: nil), forCellWithReuseIdentifier: CurrencyBalanceCell.id)
    }
    
    // MARK: - Handle Text Field changes
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, let currencyAmount = Double(text) {
            fetchExchangeRate(amount: currencyAmount, fromCurrency: chosenStateOfsellCurrencyPicker, toCurrency: chosenStateOfrecieveCurrencyPicker)
        } else if textField.text == "" {
            recieveCurrencyLabel.text = ""
        } else {
            recieveCurrencyLabel.text = "Invalid Input"
        }
    }
    
    // MARK: - Fetch Exchange Rate
    
    func fetchExchangeRate(amount: Double, fromCurrency: String, toCurrency: String) {
        ExchangeWorker.worker.run(ExchangeWorker.Body(amount: amount, inputCurrency: fromCurrency, outputCurrency: toCurrency), { [weak self] (result: Result<ExchangeWorker.Output, NetworkError>) in
            switch result {
            case .success(let response):
                self?.recieveCurrencyLabel.text = "\(response.amount)"
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    // MARK: - UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return currencyPicker.count
        } else {
            return currencyPicker.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            chosenStateOfsellCurrencyPicker = currencyPicker[row].segmentTitle
        } else {
            chosenStateOfrecieveCurrencyPicker = currencyPicker[row].segmentTitle
        }
        textFieldDidChangeSelection(sellCurrencyTextField)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 1 {
            return "\(currencyPicker[row])"
        } else {
            return "\(currencyPicker[row])"
        }
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencySymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = currencyBalanceCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyBalanceCell", for: indexPath) as! CurrencyBalanceCell
        
        let currencyBalances = Currencies.allCases.map { $0.segmentTitle }.compactMap { key in
            return UserDefaults.standard.string(forKey: key)
        }
        
        cell.symbolLabel.text = currencySymbols[indexPath.row]
        cell.balanceLabel.text = String(currencyBalances[indexPath.row])
        
        return cell
    }
    
    // MARK: - Actions

    @IBAction func submitConversionButton(_ sender: Any) {
        if chosenStateOfsellCurrencyPicker == chosenStateOfrecieveCurrencyPicker {
            return
        }
        let textFromSellCurrencyTextField = sellCurrencyTextField.text ?? ""
        var amountForSell = Double(textFromSellCurrencyTextField) ?? 0.0
        
        let textFromRecieveCurrencyLabel = recieveCurrencyLabel.text ?? ""
        let amountForRecieve = Double(textFromRecieveCurrencyLabel) ?? 0.0
        
        let currentCurrencyBalance = UserDefaultsManager.getBalance(for: chosenStateOfsellCurrencyPicker)
        let currentBalanceForRecieveCurrency = UserDefaultsManager.getBalance(for: chosenStateOfrecieveCurrencyPicker)
        
        let countOfCurrencyConversions = UserDefaultsManager.currencyConversionsCount
        
        if currentCurrencyBalance >= amountForSell {
            
            if countOfCurrencyConversions >= 5 {
                let commissionFee = amountForSell * 0.007
                showAlert(alertText:"Currency Converted",
                          alertMessage: "You have converted \(amountForSell) \(chosenStateOfsellCurrencyPicker) to \(amountForRecieve) \(chosenStateOfrecieveCurrencyPicker). Commission Fee - \(commissionFee.roundTo(places: 2)) \(chosenStateOfsellCurrencyPicker)")
                amountForSell = amountForSell + commissionFee
            }
            
            let newBalanceForSellCurrency = (currentCurrencyBalance - amountForSell).roundTo(places: 2)
            let newBalanceForRecieveCurrency = (currentBalanceForRecieveCurrency + amountForRecieve).roundTo(places: 2)
            
            UserDefaultsManager.setBalance(newBalanceForSellCurrency, for: chosenStateOfsellCurrencyPicker)
            UserDefaultsManager.setBalance(newBalanceForRecieveCurrency, for: chosenStateOfrecieveCurrencyPicker)

            UserDefaultsManager.currencyConversionsCount += 1
            
        } else {
            showAlert(alertText: "Conversion Error",
                      alertMessage: "Sorry, but you don't have enough funds to convert from \(chosenStateOfsellCurrencyPicker) to \(chosenStateOfrecieveCurrencyPicker)")
        }
        currencyBalanceCollectionView.reloadData()
    }
    
    func showAlert(alertText: String, alertMessage: String) {
        let messageAlert = UIAlertController(title: alertText,
                                             message: alertMessage,
                                             preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default)
        messageAlert.addAction(action)
        present(messageAlert, animated: true)
    }
}


//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

final class CurrencyConverterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet private weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet private weak var recieveCurrencyPicker: UIPickerView!
    @IBOutlet private weak var currencyBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var sellCurrencyTextField: UITextField!
    @IBOutlet private weak var recieveCurrencyLabel: UILabel!
    
    // MARK: - Properties
    private let debouncer = Debouncer(interval: 0.5)
    
    private var currencyPicker: [Currencies] = []
    private var chosenStateOfsellCurrencyPicker = Currencies.USD.segmentTitle
    private var chosenStateOfrecieveCurrencyPicker = Currencies.USD.segmentTitle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sellCurrencyPicker.delegate = self
        sellCurrencyPicker.dataSource = self
        recieveCurrencyPicker.delegate = self
        recieveCurrencyPicker.dataSource = self
        currencyPicker = Currencies.allCases
        
        currencyBalanceCollectionView.dataSource = self
        
        sellCurrencyTextField.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        currencyBalanceCollectionView.register(UINib(nibName: "CurrencyBalanceCell", bundle: nil), forCellWithReuseIdentifier: CurrencyBalanceCell.id)
    }
    
    // MARK: - Handle Text Field changes
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, let currencyAmount = Double(text) {
            debouncer.call {
                self.fetchExchangeRate(amount: currencyAmount, fromCurrency: self.chosenStateOfsellCurrencyPicker, toCurrency: self.chosenStateOfrecieveCurrencyPicker)
            }
        } else if textField.text == "" {
            recieveCurrencyLabel.text = ""
        } else {
            recieveCurrencyLabel.text = "Invalid Input"
        }
    }
    
    // MARK: - Fetch Exchange Rate
    
    private func fetchExchangeRate(amount: Double, fromCurrency: String, toCurrency: String) {
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
        if pickerView == sellCurrencyPicker {
            return currencyPicker.count
        } else {
            return currencyPicker.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sellCurrencyPicker {
            chosenStateOfsellCurrencyPicker = currencyPicker[row].segmentTitle
        } else {
            chosenStateOfrecieveCurrencyPicker = currencyPicker[row].segmentTitle
        }
        textFieldDidChangeSelection(sellCurrencyTextField)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView == sellCurrencyPicker {
            return "\(currencyPicker[row])"
        } else {
            return "\(currencyPicker[row])"
        }
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Currencies.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = currencyBalanceCollectionView.dequeueReusableCell(withReuseIdentifier: CurrencyBalanceCell.id, for: indexPath) as! CurrencyBalanceCell
        
        let currency = Currencies.allCases[indexPath.row]
        let currencyBalance = UserDefaultsManager.getBalance(for: currency.segmentTitle)
        let model = CurrencyCellModel(currency: currency, currencyBalance: String(currencyBalance))
        
        cell.getBalanceLabel().text = "\(model.currencyBalance) \(model.currency)"
        
        return cell
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        sellCurrencyTextField.resignFirstResponder()
    }
    
    @IBAction private func submitConversionButton(_ sender: Any) {
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
    
    private func showAlert(alertText: String, alertMessage: String) {
        let messageAlert = UIAlertController(title: alertText,
                                             message: alertMessage,
                                             preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default)
        messageAlert.addAction(action)
        present(messageAlert, animated: true)
    }
}


//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet weak var recieveCurrencyPicker: UIPickerView!
    @IBOutlet weak var currencyBalanceCollectionView: UICollectionView!
    @IBOutlet weak var sellCurrencyTextField: UITextField!
    @IBOutlet weak var recieveCurrencyLabel: UILabel!
    
    let currencySymbols = CurrencyPickerModel.allCases.map { $0.segmentTitle }
    let currencyBalances: [String] = []
    
    var currencyPicker: [CurrencyPickerModel] = []
    var chosenStateOfsellCurrencyPicker = CurrencyPickerModel.USD.segmentTitle
    var chosenStateOfrecieveCurrencyPicker = CurrencyPickerModel.USD.segmentTitle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sellCurrencyPicker.delegate = self
        self.sellCurrencyPicker.dataSource = self

        self.recieveCurrencyPicker.delegate = self
        self.recieveCurrencyPicker.dataSource = self
        
        self.currencyBalanceCollectionView.dataSource = self
        
        sellCurrencyTextField.delegate = self
        
        currencyBalanceCollectionView.register(UINib(nibName: "CurrencyBalanceCell", bundle: nil), forCellWithReuseIdentifier: CurrencyBalanceCell.id)
        
        currencyPicker = CurrencyPickerModel.allCases
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, let currencyAmount = Double(text) {
            fetchExchangeRate(amount: currencyAmount, fromCurrency: chosenStateOfsellCurrencyPicker, toCurrency: chosenStateOfrecieveCurrencyPicker)
        } else {
            recieveCurrencyLabel.text = "Invalid Input"
        }
    }
    
    func fetchExchangeRate(amount: Double, fromCurrency: String, toCurrency: String) {
        NetworkService.shared.getRequest(fromAmount: amount, fromCurrency: chosenStateOfsellCurrencyPicker, toCurrency: toCurrency, completion: { [weak self] (result: Result<CurrencyModel, NetworkError>) in
            switch result {
            case .success(let response):
                self?.recieveCurrencyLabel.text = "\(response.amount)"
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currencySymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = currencyBalanceCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyBalanceCell", for: indexPath) as! CurrencyBalanceCell
        
        let currencyBalances = CurrencyPickerModel.allCases.map { $0.segmentTitle }.compactMap { key in
            return UserDefaults.standard.string(forKey: key)
        }
        
        cell.symbolLabel.text = currencySymbols[indexPath.row]
        cell.balanceLabel.text = String(currencyBalances[indexPath.row])
        
        return cell
    }

    @IBAction func submitConversionButton(_ sender: Any) {
        if chosenStateOfsellCurrencyPicker == chosenStateOfrecieveCurrencyPicker {
            return
        }
        
        let textFromSellCurrencyTextField = sellCurrencyTextField.text ?? ""
        var amountForSell = Double(textFromSellCurrencyTextField) ?? 0.0
        
        let textFromRecieveCurrencyLabel = recieveCurrencyLabel.text ?? ""
        let amountForRecieve = Double(textFromRecieveCurrencyLabel) ?? 0.0
        
        let currentCurrencyBalance = UserDefaultsService.shared.getCurrencyBalance(forCurrency: chosenStateOfsellCurrencyPicker)
        let currentBalanceForRecieveCurrency = UserDefaultsService.shared.getCurrencyBalance(forCurrency: chosenStateOfrecieveCurrencyPicker)
        
        let countOfCurrencyConversions = UserDefaultsService.shared.getCountOfCurrencyConverions()
        
        if currentCurrencyBalance >= amountForSell {
            if countOfCurrencyConversions > 5 {
                let commissionFee = amountForSell * 0.007
                showAlert(alertText: "Currency Converted", alertMessage: "You have converted \(amountForSell) \(chosenStateOfsellCurrencyPicker) to \(amountForRecieve) \(chosenStateOfrecieveCurrencyPicker). Commission Fee - \(commissionFee) \(chosenStateOfsellCurrencyPicker)")
                amountForSell = amountForSell + commissionFee
            }
            let newBalanceForSellCurrency = currentCurrencyBalance - amountForSell
            let newBalanceForRecieveCurrency = currentBalanceForRecieveCurrency + amountForRecieve
            
            UserDefaultsService.shared.changeCurrencyBalance(newBalance: newBalanceForSellCurrency, forCurrency: chosenStateOfsellCurrencyPicker)
            UserDefaultsService.shared.changeCurrencyBalance(newBalance: newBalanceForRecieveCurrency, forCurrency: chosenStateOfrecieveCurrencyPicker)
            UserDefaultsService.shared.increaseCountOfCurrencyConversions()
        } else {
            showAlert(alertText: "Conversion Error", alertMessage: "Sorry, but you don't have enough funds to convert from \(chosenStateOfsellCurrencyPicker) to \(chosenStateOfrecieveCurrencyPicker)")
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


//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UITextFieldDelegate {
    
    let currencySymbols = CurrencyPickerModel.allCases.map { $0.segmentTitle }
    let currencyBalances = CurrencyPickerModel.allCases.map { $0.segmentTitle }.compactMap { key in
        return UserDefaults.standard.string(forKey: key)
    }
    
    @IBOutlet weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet weak var recieveCurrencyPicker: UIPickerView!
    @IBOutlet weak var currencyBalanceCollectionView: UICollectionView!
    @IBOutlet weak var sellCurrencyTextField: UITextField!
    @IBOutlet weak var recieveCurrencyLabel: UILabel!
    
    var pickerData: [CurrencyPickerModel] = []
    var amountData: Double = 0.00
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
        
        pickerData = CurrencyPickerModel.allCases
        
        UserDefaultsService.shared.getData()
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
                self?.recieveCurrencyLabel.text = "+ \(response.amount)"
                print(response.amount)
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
            return pickerData.count
        } else {
            return pickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            chosenStateOfsellCurrencyPicker = pickerData[row].segmentTitle
        } else {
            chosenStateOfrecieveCurrencyPicker = pickerData[row].segmentTitle
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 1 {
            return "\(pickerData[row])"
        } else {
            return "\(pickerData[row])"
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(currencySymbols.count)
        return currencySymbols.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = currencyBalanceCollectionView.dequeueReusableCell(withReuseIdentifier: "CurrencyBalanceCell", for: indexPath) as! CurrencyBalanceCell
        
        cell.symbolLabel.text = currencySymbols[indexPath.row]
        cell.balanceLabel.text = String(currencyBalances[indexPath.row])
        
        return cell
    }
    
}


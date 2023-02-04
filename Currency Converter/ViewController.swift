//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet weak var recieveCurrencyPicker: UIPickerView!
    
    var pickerData: [CurrencyPickerModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sellCurrencyPicker.delegate = self
        self.sellCurrencyPicker.dataSource = self
        
        self.recieveCurrencyPicker.delegate = self
        self.recieveCurrencyPicker.dataSource = self
        
        pickerData = CurrencyPickerModel.allCases
        
        fetchExchangeRate()
    }
    
    func fetchExchangeRate() {
        NetworkService.shared.getRequest(fromAmount: 340.51, fromCurrency: "EUR", toCurrency: "USD", completion: { [weak self] (result: Result<CurrencyModel, NetworkError>) in
            switch result {
            case .success(let response):
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
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if pickerView.tag == 1 {
            return "\(pickerData[row])"
        } else {
            return "\(pickerData[row])"
        }
    }
    
}


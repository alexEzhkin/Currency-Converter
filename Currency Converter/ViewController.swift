//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionCellSize: CGSize {
        let size = 50
        
        return CGSize(width: size, height: size)
    }
    
    let currencySymbols = ["$", "€", "¥", "$", "€", "¥", "$", "€", "¥", "$", "€", "¥"]
    let currencyBalances = [100.0, 200.0, 300.0, 100.0, 200.0, 300.0, 100.0, 200.0, 300.0, 100.0, 200.0, 300.0]
    
    @IBOutlet weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet weak var recieveCurrencyPicker: UIPickerView!
    @IBOutlet weak var currencyBalanceCollectionView: UICollectionView!
    
    var pickerData: [CurrencyPickerModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sellCurrencyPicker.delegate = self
        self.sellCurrencyPicker.dataSource = self

        self.recieveCurrencyPicker.delegate = self
        self.recieveCurrencyPicker.dataSource = self
        
        self.currencyBalanceCollectionView.delegate = self
        self.currencyBalanceCollectionView.dataSource = self
        
        currencyBalanceCollectionView.register(UINib(nibName: "CurrencyBalanceCell", bundle: nil), forCellWithReuseIdentifier: CurrencyBalanceCell.id)
        
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return collectionCellSize
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


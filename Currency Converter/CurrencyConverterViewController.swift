//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

final class CurrencyConverterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate {
    
    @IBOutlet private weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet private weak var recieveCurrencyPicker: UIPickerView!
    @IBOutlet private weak var currencyBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var sellCurrencyTextField: UITextField!
    @IBOutlet private weak var recieveCurrencyLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    
    // MARK: - Properties
    var debouncer: Debouncer?
    
    // MARK: - External dependencies
    var exchangeWorker: ExchangeWorker!
    
    private var currencies: [Currencies] = []
    private var sellCurrencyPickerState = Currencies.USD.segmentTitle
    private var recieveCurrencyPickerState = Currencies.USD.segmentTitle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPickerViews()
        setUpCollectionView()
        setUpTextField()
        configurateUIElemtns()
        
        currencies = Currencies.allCases
                
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setups
    func setUpPickerViews() {
        sellCurrencyPicker.delegate = self
        sellCurrencyPicker.dataSource = self
        recieveCurrencyPicker.delegate = self
        recieveCurrencyPicker.dataSource = self
    }
    
    func setUpCollectionView() {
        currencyBalanceCollectionView.dataSource = self
        currencyBalanceCollectionView.register(UINib(nibName: "CurrencyBalanceCell", bundle: nil), forCellWithReuseIdentifier: CurrencyBalanceCell.id)
    }
    
    func setUpTextField() {
        sellCurrencyTextField.delegate = self
    }
    
    func configurateUIElemtns() {
        submitButton.layer.cornerRadius = submitButton.frame.height/2
    }
    
    // MARK: - Handle Text Field changes
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let endPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: endPosition,
                                                          to: endPosition)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let text = textField.text, let currencyAmount = Double(text) {
            debouncer?.call { [weak self] in
                guard let self else { return }
                self.fetchExchangeRate(amount: currencyAmount,
                                       fromCurrency: self.sellCurrencyPickerState,
                                       toCurrency: self.recieveCurrencyPickerState)
            }
        } else if textField.text == "" {
            recieveCurrencyLabel.text = ""
        } else {
            recieveCurrencyLabel.text = "Invalid Input"
        }
    }
    
    // MARK: - Fetch Exchange Rate
    
    private func fetchExchangeRate(amount: Double, fromCurrency: String, toCurrency: String) {
        exchangeWorker.run(ExchangeWorker.Body(amount: amount,
                                               inputCurrency: fromCurrency,
                                               outputCurrency: toCurrency), { [weak self] result in
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
        currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let segmentTitle = currencies[row].segmentTitle
        
        if pickerView == sellCurrencyPicker {
            sellCurrencyPickerState = segmentTitle
        } else {
            recieveCurrencyPickerState = segmentTitle
        }
        textFieldDidChangeSelection(sellCurrencyTextField)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(currencies[row])"
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = currencyBalanceCollectionView.dequeueReusableCell(withReuseIdentifier: CurrencyBalanceCell.id,
                                                                     for: indexPath) as! CurrencyBalanceCell
        
        let currency = currencies[indexPath.row]
        let currencyBalance = CurrencyUserDefaultsManager.getBalance(for: currency.segmentTitle)
        
        cell.configure(
            model: CurrencyBalanceCell.Model(
                currency: currency,
                currencyBalance: currencyBalance))
        
        return cell
    }
    
    // MARK: - Actions
    
    @objc private func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        sellCurrencyTextField.resignFirstResponder()
    }
    
    @IBAction private func submitConversionButton(_ sender: Any) {
        if sellCurrencyPickerState == recieveCurrencyPickerState {
            return
        }
        
        var amountForSell = sellCurrencyTextField.text.flatMap(Double.init) ?? .zero
        var amountForRecieve = recieveCurrencyLabel.text.flatMap(Double.init) ?? .zero
        
        let currentCurrencyBalance = CurrencyUserDefaultsManager.getBalance(for: sellCurrencyPickerState)
        let currentBalanceForRecieveCurrency = CurrencyUserDefaultsManager.getBalance(for: recieveCurrencyPickerState)
        
        let countOfCurrencyConversions = CurrencyUserDefaultsManager.currencyConversionsCount
                
        guard currentCurrencyBalance >= amountForSell else {
            return showConversionErrorAlert()
        }
        
        if countOfCurrencyConversions >= 5 {
            let commissionFee = amountForSell * 0.007
            showComissionFeeAlert(sellAmount: amountForSell,
                                  recieveAmount: amountForRecieve,
                                  commissionFee: commissionFee)
            amountForSell = amountForSell + commissionFee
        }
        
        let newBalanceForSellCurrency = (currentCurrencyBalance - amountForSell).roundTo(places: 2)
        let newBalanceForRecieveCurrency = (currentBalanceForRecieveCurrency + amountForRecieve).roundTo(places: 2)
        
        CurrencyUserDefaultsManager.setBalance(newBalanceForSellCurrency,
                                               for: sellCurrencyPickerState)
        CurrencyUserDefaultsManager.setBalance(newBalanceForRecieveCurrency,
                                               for: recieveCurrencyPickerState)
        CurrencyUserDefaultsManager.currencyConversionsCount += 1
        
        currencyBalanceCollectionView.reloadData()
    }
    
    // MARK: - Alerts
    
    private func showComissionFeeAlert(sellAmount: Double, recieveAmount: Double, commissionFee: Double) {
        let messageAlert = UIAlertController(title: "Currency Converted",
                                             message: "You have converted \(sellAmount) \(sellCurrencyPickerState) to \(recieveAmount) \(recieveCurrencyPickerState). Commission Fee - \(commissionFee.roundTo(places: 2)) \(sellCurrencyPickerState)",
                                             preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default)
        messageAlert.addAction(action)
        present(messageAlert, animated: true)
    }
    
    private func showConversionErrorAlert() {
        let messageAlert = UIAlertController(title: "Conversion Error",
                                             message: "Sorry, but you don't have enough funds to convert from \(sellCurrencyPickerState) to \(recieveCurrencyPickerState)",
                                             preferredStyle: .alert)
        let action = UIAlertAction(title: "Done", style: .default)
        messageAlert.addAction(action)
        present(messageAlert, animated: true)
    }
}


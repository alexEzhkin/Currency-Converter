//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

final class CurrencyConverterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UICollectionViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate {
    
    // MARK: - UI Elements
    
    @IBOutlet private weak var sellCurrencyPicker: UIPickerView!
    @IBOutlet private weak var recieveCurrencyPicker: UIPickerView!
    @IBOutlet private weak var currencyBalanceCollectionView: UICollectionView!
    @IBOutlet private weak var sellCurrencyTextField: UITextField!
    @IBOutlet private weak var recieveCurrencyTextField: UITextField!
    @IBOutlet private weak var submitButton: UIButton!
    
    // MARK: - External dependencies
    
    var exchangeWorker: ExchangeWorker!
    var debouncer: Debouncer!
    var currencies: [Currencies] = []
    
    // MARK: - Properties
    
    private lazy var sellCurrencyPickerState = currencies.first?.segmentTitle ?? ""
    private lazy var recieveCurrencyPickerState = currencies.first?.segmentTitle ?? ""
    
    //MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpPickerViews()
        setUpCollectionView()
        setUpTextField()
        setUpButton()
        setUpNavigationBar()
        setUpView()
    }
    
    // MARK: - Setups
    
    private func setUpPickerViews() {
        sellCurrencyPicker.delegate = self
        sellCurrencyPicker.dataSource = self
        recieveCurrencyPicker.delegate = self
        recieveCurrencyPicker.dataSource = self
    }
    
    private func setUpCollectionView() {
        currencyBalanceCollectionView.dataSource = self
        currencyBalanceCollectionView.register(UINib(nibName: "CurrencyBalanceCell", bundle: nil), forCellWithReuseIdentifier: CurrencyBalanceCell.id)
    }
    
    private func setUpTextField() {
        sellCurrencyTextField.delegate = self
        recieveCurrencyTextField.isEnabled = false
    }
    
    private func setUpButton() {
        submitButton.layer.cornerRadius = submitButton.frame.height/2
        submitButton.layer.shadowColor = UIColor.gray.cgColor
        submitButton.layer.shadowRadius = 2.0
        submitButton.layer.shadowOpacity = 0.5
        submitButton.layer.shadowOffset = CGSize(width: 3, height: 2)
    }
    
    private func setUpNavigationBar() {
        let navigationBarColor = UIColor(red: CGFloat(1/255.0), green: CGFloat(152/255.0), blue: CGFloat(218/255.0), alpha: CGFloat(1.0))
        
        self.navigationItem.title = "Currency Converter"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.backgroundColor = navigationBarColor
        self.navigationController?.setStatusBar(backgroundColor: navigationBarColor)
    }
    
    private func setUpView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Handle Text Field changes
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let endPosition = textField.endOfDocument
        textField.selectedTextRange = textField.textRange(from: endPosition,
                                                          to: endPosition)
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        textField.text = textField.text?.replacingOccurrences(of: ",", with: ".")

        if let text = textField.text, let currencyAmount = Double(text) {
            fetchExchangeRate(amount: currencyAmount,
                              fromCurrency: self.sellCurrencyPickerState,
                              toCurrency: self.recieveCurrencyPickerState)
        } else if textField.text == "" {
            recieveCurrencyTextField.text = ""
        } else {
            recieveCurrencyTextField.text = "Invalid Input"
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        if (textField.text?.contains("."))! && string == "." {
            return false
        }
        if (textField.text?.contains("."))! {
            let decimalPlace = textField.text?.components(separatedBy: ".").last
            if (decimalPlace?.count)! < Constants.roundedPlace {
                return true
            }
            else {
                return false
            }
        }
        return true
    }
    
    // MARK: - Fetch Exchange Rate
    
    private func fetchExchangeRate(amount: Double, fromCurrency: String, toCurrency: String) {
        debouncer.call { [weak self] in
            guard let self else { return }
            self.exchangeWorker.run(ExchangeWorker.Body(amount: amount,
                                                        inputCurrency: fromCurrency,
                                                        outputCurrency: toCurrency), { [weak self] result in
                switch result {
                case .success(let response):
                    if self?.sellCurrencyTextField.text?.isEmpty == true {
                        self?.recieveCurrencyTextField.text = ""
                        return
                    }
                    self?.recieveCurrencyTextField.text = "+\(response.amount)"
                case .failure(let error):
                    print(error.localizedDescription)
                }
            })
        }
    }
    
    // MARK: - UIPickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let segmentTitle = currencies[safe: row]?.segmentTitle else { return }
        
        if pickerView == sellCurrencyPicker {
            sellCurrencyPickerState = segmentTitle
        } else {
            recieveCurrencyPickerState = segmentTitle
        }
        textFieldDidChangeSelection(sellCurrencyTextField)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let currencyTitle = currencies[safe: row] else { return "N/A"}
        
        return "\(currencyTitle)"
    }
    
    // MARK: - UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currencies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = currencyBalanceCollectionView.dequeueReusableCell(withReuseIdentifier: CurrencyBalanceCell.id, for: indexPath) as! CurrencyBalanceCell
        
        guard let currency = currencies[safe: indexPath.row] else { return cell }
        
        let currencyBalance = CurrencyUserDefaultsManager.getBalance(for: currency.segmentTitle)
        let formattedCurrencyBalance = String(format: "%.2f", currencyBalance)
        
        cell.configure(
            model: CurrencyBalanceCell.Model(
                currency: currency,
                currencyBalance: formattedCurrencyBalance))
        
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
        let amountForRecieve = recieveCurrencyTextField.text.flatMap(Double.init) ?? .zero
        let commissionFee = amountForSell * Constants.commissionAmount
        
        let currentCurrencyBalance = CurrencyUserDefaultsManager.getBalance(for: sellCurrencyPickerState)
        let currentBalanceForRecieveCurrency = CurrencyUserDefaultsManager.getBalance(for: recieveCurrencyPickerState)
        
        let countOfCurrencyConversions = CurrencyUserDefaultsManager.currencyConversionsCount
        
        guard (countOfCurrencyConversions <= Constants.numberOfFreeConversions && currentCurrencyBalance >= amountForSell) || (countOfCurrencyConversions >= Constants.numberOfFreeConversions && currentCurrencyBalance >=  (amountForSell+commissionFee)) else {
            return showConversionErrorAlert()
        }
        
        if countOfCurrencyConversions >= Constants.numberOfFreeConversions {
            showComissionFeeAlert(sellAmount: amountForSell,
                                  recieveAmount: amountForRecieve,
                                  commissionFee: commissionFee)
            amountForSell = amountForSell + commissionFee
        }
        
        let newBalanceForSellCurrency = (currentCurrencyBalance - amountForSell).roundTo(places: Constants.roundedPlace)
        let newBalanceForRecieveCurrency = (currentBalanceForRecieveCurrency + amountForRecieve).roundTo(places: Constants.roundedPlace)
        
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
                                             message: "You have converted \(sellAmount) \(sellCurrencyPickerState) to \(recieveAmount) \(recieveCurrencyPickerState). Commission Fee - \(commissionFee.roundTo(places: Constants.roundedPlace)) \(sellCurrencyPickerState)",
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

private extension CurrencyConverterViewController {
    
    enum Constants {
        static let numberOfFreeConversions = 5
        static let commissionAmount = 0.007
        static let roundedPlace = 2
    }
}


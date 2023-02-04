//
//  ViewController.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
}


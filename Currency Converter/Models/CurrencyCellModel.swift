//
//  CurrencyCellModel.swift
//  Currency Converter
//
//  Created by Alex on 5.02.23.
//

import Foundation

struct CurrencyCellModel {
    var currency: Currencies
    var currencyBalance: String
    
    init(currency: Currencies, currencyBalance: String) {
        self.currency = currency
        self.currencyBalance = currencyBalance
    }
}

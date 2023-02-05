//
//  UserDefaultsService.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import Foundation

class UserDefaultsService {
    private init() { }
    
    static let shared = UserDefaultsService()
    
    let defaults = UserDefaults.standard
    
    func getCountOfCurrencyConverions() -> Int {
        return defaults.integer(forKey: "CurrencyConversions")
    }
    
    func increaseCountOfCurrencyConversions() {
        var originalValue = defaults.integer(forKey: "CurrencyConversions")
        originalValue += 1
        defaults.set(originalValue, forKey: "CurrencyConversions")
        print(defaults.integer(forKey: "CurrencyConversions"))
    }
    
    func getCurrencyBalance(forCurrency: String) -> Double {
        return defaults.double(forKey: forCurrency)
    }
    
    func changeCurrencyBalance(newBalance: Double, forCurrency: String) {
        defaults.set(newBalance, forKey: forCurrency)
    }
}

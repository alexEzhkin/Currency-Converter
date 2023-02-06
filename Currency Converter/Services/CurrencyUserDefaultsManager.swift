//
//  UserDefaultsService.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import Foundation

struct CurrencyUserDefaultsManager {
    private static let userDefaults = UserDefaults.standard
    
    static let currencyConversionsKey = "CurrencyConversions"
    
    static var currencyConversionsCount = userDefaults.integer(forKey: currencyConversionsKey) {
        didSet {
            userDefaults.set(currencyConversionsCount, forKey: currencyConversionsKey)
        }
    }
    
    static func getBalance(for currency: String) -> Double {
        userDefaults.double(forKey: currency)
    }
    
    static func setBalance(_ balance: Double, for currency: String) {
        userDefaults.set(balance, forKey: currency)
    }
    
    static func registerInitialDefaults(_ defaultValues: [String: Any]) {
        userDefaults.register(defaults: defaultValues)
    }
}

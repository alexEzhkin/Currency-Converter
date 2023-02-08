//
//  UserDefaultsService.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import Foundation

struct CurrencyUserDefaultsManager {
    private static let userDefaults = UserDefaults.standard
    
    private static let currencyConversionsKey = "CurrencyConversions"
    
    static func registerInitialDefaults() {
        userDefaults.register(defaults: [currencyConversionsKey : 0])
        userDefaults.register(defaults: [Currencies.EUR.segmentTitle : 1000.00])
        userDefaults.register(defaults: [Currencies.USD.segmentTitle : 0.00])
        userDefaults.register(defaults: [Currencies.JPY.segmentTitle: 0.00])
    }
    
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
}

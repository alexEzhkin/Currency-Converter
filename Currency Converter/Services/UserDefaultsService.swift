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
    
    func getCurrencyBalance(forCurrency: String) -> Double {
        return defaults.double(forKey: forCurrency)
    }
    
    func changeCurrencyBalance(newBalance: Double, forCurrency: String) {
        defaults.set(newBalance, forKey: forCurrency)
    }
}

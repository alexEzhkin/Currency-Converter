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
    
    func getData() {
        print(defaults.value(forKey: "USD"))
        print(defaults.value(forKey: "EUR"))
        print(defaults.value(forKey: "JPY"))
    }
}

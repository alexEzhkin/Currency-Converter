//
//  AppDelegate.swift
//  Currency Converter
//
//  Created by Alex on 3.02.23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UserDefaultsManager.registerInitialDefaults(["CurrencyConversions": 0, "USD": 1000.00, "EUR": 0.00, "JPY": 0.00])
        return true
    }
}


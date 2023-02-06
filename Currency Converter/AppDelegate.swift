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
        
        self.window = CurrencyWindowManager.setupInitialViewController(exchangeWorkerRequest: .currency, debouncerInterval: 0.5)
        
        let initialCurrencyBalance = [CurrencyUserDefaultsManager.currencyConversionsKey: 0,
                                      Currencies.USD.segmentTitle: 1000.00,
                                      Currencies.EUR.segmentTitle: 0.00,
                                      Currencies.JPY.segmentTitle: 0.00]
        CurrencyUserDefaultsManager.registerInitialDefaults(initialCurrencyBalance)
        
        return true
    }
}


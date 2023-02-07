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
        
        setupInitialViewController(exchangeWorkerRequest: .currency, debouncerInterval: 0.5)
        
        CurrencyUserDefaultsManager.registerInitialDefaults()
        
        return true
    }
}

private extension AppDelegate {
    func setupInitialViewController(exchangeWorkerRequest: ExchangeWorker, debouncerInterval: Double) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window = window
        
        let storyboard = UIStoryboard(name: "CurrencyConverter", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyConverterViewController") as! CurrencyConverterViewController
        
        initialViewController.exchangeWorker = exchangeWorkerRequest
        initialViewController.debouncer = Debouncer(interval: debouncerInterval)
        initialViewController.currencies = Currencies.allCases
        
        window.rootViewController = UINavigationController(rootViewController: initialViewController)
        window.makeKeyAndVisible()
    }
}


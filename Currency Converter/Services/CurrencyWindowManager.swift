//
//  WindowManager.swift
//  Currency Converter
//
//  Created by Alex on 6.02.23.
//

import UIKit

final class CurrencyWindowManager {
    static func setupInitialViewController(exchangeWorkerRequest: ExchangeWorker) -> UIWindow {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "CurrencyConverter", bundle: nil)
        
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "CurrencyConverterViewController") as! CurrencyConverterViewController
        initialViewController.exchangeWorker = exchangeWorkerRequest
        
        window.rootViewController = initialViewController
        window.makeKeyAndVisible()
        
        return window
    }
}

//
//  CurrencyPickerModel.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import Foundation

enum Currencies: Int, CaseIterable {
    case EUR
    case USD
    case JPY
    
    var segmentIndex: Int {
        return rawValue
    }
    
    var segmentTitle: String {
        return String(describing: self)
    }
}

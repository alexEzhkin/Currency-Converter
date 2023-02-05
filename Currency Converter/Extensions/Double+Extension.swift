//
//  Double+Extension.swift
//  Currency Converter
//
//  Created by Alex on 5.02.23.
//

import Foundation

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

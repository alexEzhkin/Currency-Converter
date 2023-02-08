//
//  Array+Extension.swift
//  Currency Converter
//
//  Created by Alex on 7.02.23.
//

import Foundation

extension Array {
    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
    
    func item(at index: Int) -> Element? {
        guard 0..<count ~= index else { return nil }
        return self[index]
    }
}

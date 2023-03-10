//
//  ReusableView.swift
//  Currency Converter
//
//  Created by Alex on 6.02.23.
//

import UIKit

protocol ReusableView {
    static var id: String { get }
}

extension ReusableView where Self: UIView {
    static var id: String {
        return String(describing: self)
    }
}

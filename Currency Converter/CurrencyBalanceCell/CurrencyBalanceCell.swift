//
//  CurrencyBalanceCell.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import UIKit

final class CurrencyBalanceCell: UICollectionViewCell, ReusableView {
    
    @IBOutlet private weak var balanceLabel: UILabel!
    
}

extension CurrencyBalanceCell {
    
    struct Model {
        let currency: Currencies
        let currencyBalance: String
    }
    
    func configure(model: Model) {
        balanceLabel.text = "\(String(model.currencyBalance)) \(model.currency)"
    }
}

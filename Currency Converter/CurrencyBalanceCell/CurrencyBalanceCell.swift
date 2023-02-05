//
//  CurrencyBalanceCell.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import UIKit

final class CurrencyBalanceCell: UICollectionViewCell, ReusableView {
    
    @IBOutlet private weak var balanceLabel: UILabel!
        
    func getBalanceLabel() -> UILabel {
        return balanceLabel
    }
}

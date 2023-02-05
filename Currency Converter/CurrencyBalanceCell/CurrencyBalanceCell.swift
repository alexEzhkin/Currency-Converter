//
//  CurrencyBalanceCell.swift
//  Currency Converter
//
//  Created by Alex on 4.02.23.
//

import Foundation
import UIKit

class CurrencyBalanceCell: UICollectionViewCell {
    
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    static let id = "CurrencyBalanceCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

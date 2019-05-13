//
//  MonthlyCellCollectionViewCell.swift
//  GigP
//
//  Created by Krishna Vemulapali on 2019-04-22.
//  Copyright © 2019 Krishna Vemulapali. All rights reserved.
//

import UIKit
import MaterialComponents.MDCCardCollectionCell


class MonthlyCellCollectionViewCell: MDCCardCollectionCell {
    
    @IBOutlet var month: UILabel!
    @IBOutlet var monthlyEarnings: UILabel!
    
    @IBOutlet var monthlyHours: UILabel!
    @IBOutlet var monthlyHST: UILabel!
    
    @IBOutlet var monthlyExpense: UILabel!
}

//
//  ManagePaymentCell.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/11/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

class ManagePaymentCell: UICollectionViewCell {
    
    @IBOutlet weak var paymentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.borderWidth = 1
        layer.cornerRadius = 5
    }
    
}

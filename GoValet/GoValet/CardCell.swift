//
//  CardCell.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/12/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {

    @IBOutlet weak var setAsDefaultButton: UIButton!
    @IBOutlet weak var cardNoLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func setAsDefaultButtonaction(sender: AnyObject) {
    }
  
    @IBAction func closeButtonAction(sender: UIButton) {
    }
}

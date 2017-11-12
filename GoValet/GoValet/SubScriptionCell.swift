//
//  SubScriptionCell.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/12/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

class SubScriptionCell: UICollectionViewCell {

    @IBOutlet weak var subscriptionCell: UILabel!
    @IBOutlet weak var subscriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        // Initialization code
    }
    
    func setSelectedBorder(){
        self.layer.borderColor = UIColor(patternImage: UIImage(named: "gradiant")!).CGColor // Golden Color
    }
    func setUnSelectedBorder(){
        self.layer.borderColor = UIColor(red:0.07, green:0.56, blue:0.58, alpha:1.0).CGColor //Blue Color
    }

}

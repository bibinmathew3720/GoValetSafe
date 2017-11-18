//
//  CardCell.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/12/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

protocol CardCellDelegate: class {
    
    func setAsDefaultButtonActionDelegate(cellTag:Int)
    func deleteButtonActionDelegate(cellTag:Int)
}

class CardCell: UICollectionViewCell {

    @IBOutlet weak var setAsDefaultButton: UIButton!
    @IBOutlet weak var cardIV: UIImageView!
    @IBOutlet weak var cardNoLabel: UILabel!
    weak var delegate: CardCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func setAsDefaultButtonaction(sender: AnyObject) {
        delegate?.setAsDefaultButtonActionDelegate(self.tag)
    }
  
    @IBAction func closeButtonAction(sender: UIButton) {
        delegate?.deleteButtonActionDelegate(self.tag)
    }
}

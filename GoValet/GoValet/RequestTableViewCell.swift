
//
//  RequestTableViewCell.swift
//  GoValet
//
//  Created by Ajeesh T S on 26/01/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

protocol RequestCellDelegate : class {
    func cancelButtonClicked(cell:RequestTableViewCell)
    func callButtonClicked(cell:RequestTableViewCell)
    func readyButtonClicked(cell:RequestTableViewCell)
    func imageButtonClicked(cell:RequestTableViewCell)


}

class RequestTableViewCell: UITableViewCell {

    @IBOutlet weak var carImageView : UIImageView!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var ticketLbl : UILabel!
    weak var delegate: RequestCellDelegate?
    var request : ValetRequest?
    var row = Int()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func showData(){
        if let name = self.request?.first_name{
            nameLbl.text = "Name : \(name)"
        }
        if let name = self.request?.valet_code{
            ticketLbl.text = name
        }else{
            ticketLbl.text = "Ticket : Click on image"
        }
        if let imageUrl = self.request?.valet_image{
            carImageView.sd_setImageWithURL(NSURL(string:(imageUrl)))
        }
    }
    
    
    @IBAction func callBtnClicked(){
        self.delegate?.callButtonClicked(self)
    }

    @IBAction func cancelBtnClicked(){
        self.delegate?.cancelButtonClicked(self)
    }
    
    @IBAction func readyBtnClicked(){
        self.delegate?.readyButtonClicked(self)
    }
    
    @IBAction func imageBtnClicked(){
        self.delegate?.imageButtonClicked(self)
    }
}

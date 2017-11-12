//
//  AddCardVC.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/12/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

class AddCardVC: UIViewController {
    @IBOutlet weak var firstNameTF: CustomTextField!

    @IBOutlet weak var cvvTF: CustomTextField!
    @IBOutlet weak var myCardView: UIView!
    @IBOutlet weak var expiryYearTF: CustomTextField!
    @IBOutlet weak var expiryMonthTF: CustomTextField!
    @IBOutlet weak var cardNoTF: CustomTextField!
    @IBOutlet weak var lastNameTF: CustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLogo()
        self.title = "PAYMENT".localized
        self.changeNavTitleColor()
        self.customisingTextFields()
        // Do any additional setup after loading the view.
    }
    
    func customisingTextFields(){
        firstNameTF.roundCorner()
        lastNameTF.roundCorner()
        cardNoTF.roundCorner()
        expiryMonthTF.roundCorner()
        expiryYearTF.roundCorner()
        cvvTF.roundCorner()
        myCardView.roundCornerValue(2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func addPaymentButtonAction(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

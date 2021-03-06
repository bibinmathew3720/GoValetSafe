//
//  AddCardVC.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/12/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit
import Alamofire
enum CardServiceType {
    case AddCardService
    case GetAllCards
    case DeleteCard
    case SetAsDefaultCard
}
class AddCardVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,CardCellDelegate {
    var cardsArray = NSArray()
    
    @IBOutlet weak var myCardsLabel: UILabel!
    @IBOutlet weak var addACardLabel: UILabel!
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var poweredByPayPalLable: UILabel!
    
    @IBOutlet weak var cardsCollectionView: UICollectionView!
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
        self.initialisation()
        cardsCollectionView.registerNib(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "cardCell")
        self.changeNavTitleColor()
        self.customisingTextFields()
        getAllCards()
        // Do any additional setup after loading the view.
    }
    
    func initialisation(){
       self.title = "PAYMENT".localized
       self.addACardLabel.text = "ADD A NEW CARD".localized
        self.myCardsLabel.text = "MY CARD(S)".localized
       self.poweredByPayPalLable.text = "Powered by PayPal".localized
       self.addPaymentButton .setTitle("ADD PAYMENT METHOD".localized, forState: .Normal)
       self.firstNameTF.placeholder = "FIRST NAME".localized
       self.firstNameTF.placeHolderColor = UIColor.whiteColor()
       self.lastNameTF.placeholder = "LAST NAME".localized
       self.lastNameTF.placeHolderColor = UIColor.whiteColor()
       self.cardNoTF.placeholder = "CARD NUMBER".localized
        self.cardNoTF.placeHolderColor = UIColor.whiteColor()
        self.cvvTF.placeholder = "CVV".localized
        self.cvvTF.placeHolderColor = UIColor.whiteColor()
        self.expiryYearTF.placeholder = "EXPIRY YEAR".localized
        self.expiryYearTF.placeHolderColor = UIColor.whiteColor()
        self.expiryMonthTF.placeholder = "EXPIRY MONTH".localized
        self.expiryMonthTF.placeHolderColor = UIColor.whiteColor()
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
    
    func getAllCards(){
        self.addLoaingIndicator()
        let token = UserInfo.currentUser()?.token
        var params = [String: AnyObject]()
        params["device_token"] = token
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            params["lang"] = "arabic"
        }
        else{
            params["lang"] = "eng"
        }
        postServiceWithApiType(params, type: .GetAllCards)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Collection View Datasources
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cardsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cardCell:CardCell = collectionView.dequeueReusableCellWithReuseIdentifier("cardCell", forIndexPath: indexPath) as! CardCell
        let cardDetails = self.cardsArray.objectAtIndex(indexPath.row)
        let cardNo:String = cardDetails["card_num_disp"] as! String
        if cardDetails["is_default"] as! String == "1"{
            cardCell.setAsDefaultButton.hidden = true
        }
        else{
            cardCell.setAsDefaultButton.hidden = false
        }
        
        if(cardDetails["type"] as! String == "visa"){
            cardCell.cardIV.image = UIImage(named: "visa")
        }
        else if(cardDetails["type"] as! String == "ae"){
            cardCell.cardIV.image = UIImage(named: "ae")
        }
        else if(cardDetails["type"] as! String == "jcb"){
            cardCell.cardIV.image = UIImage(named: "jcb")
        }
        else if(cardDetails["type"] as! String == "maestro"){
            cardCell.cardIV.image = UIImage(named: "maestro")
        }
        else{
           cardCell.cardIV.image = UIImage(named: "visa") 
        }
        cardCell.cardNoLabel.text = cardNo
        cardCell.tag = indexPath.row
        cardCell.delegate = self
        return cardCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    //MARK: Collection View Delegates
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 5.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(self.view.frame.width)
        return CGSize(width:collectionView.frame.width, height: 80)
    }
    
    //MARK: Card Cell Delegates
    
    func deleteButtonActionDelegate(cellTag: NSInteger) {
        let cardDetails = self.cardsArray.objectAtIndex(cellTag)
        self.addLoaingIndicator()
        let token = UserInfo.currentUser()?.token
        var params = [String: AnyObject]()
        let cardId:String = cardDetails["id"] as! String
        params["device_token"] = token
        params["card_id"] = cardId
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            params["lang"] = "arabic"
        }
        else{
            params["lang"] = "eng"
        }
        postServiceWithApiType(params, type: .DeleteCard)
    }
    func setAsDefaultButtonActionDelegate(cellTag: NSInteger) {
        
        let cardDetails = self.cardsArray.objectAtIndex(cellTag)
        self.addLoaingIndicator()
        let token = UserInfo.currentUser()?.token
        var params = [String: AnyObject]()
        let cardId:String = cardDetails["id"] as! String
        params["device_token"] = token
        params["card_id"] = cardId
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            params["lang"] = "arabic"
        }
        else{
            params["lang"] = "eng"
        }
        postServiceWithApiType(params, type: .SetAsDefaultCard)
    }
    
    //MARK: Button Actions
    

    @IBAction func addPaymentButtonAction(sender: AnyObject) {
        if isValidateCredential() == true{
            self.addLoaingIndicator()
            
            let token = UserInfo.currentUser()?.token
            var params = [String: AnyObject]()
            params["device_token"] = token
            params["first_name"] = self.firstNameTF.text
            params["last_name"] = self.lastNameTF.text
            params["card_number"] = self.cardNoTF.text
            params["expire_month"] = self.expiryMonthTF.text
            params["expire_year"] = self.expiryYearTF.text
            params["cvv"] = self.cvvTF.text
            let currentLanguage = NSLocale.preferredLanguages()[0]
            if currentLanguage == "ar-US"{
                params["lang"] = "arabic"
            }
            else{
                params["lang"] = "eng"
            }
            postServiceWithApiType(params, type: .AddCardService)
        }
        
    }
    
    func isValidateCredential() -> Bool{
        if firstNameTF.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter First Name".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }
        if lastNameTF.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Last Name".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }
        if cardNoTF.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Card No".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }
        
        if expiryMonthTF.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Expiry Month".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }
        
        if expiryYearTF.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Expiry Year".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }
        if cvvTF.text?.isBlank == true{
            UtilityMethods.showAlert("Please Enter CVV Number".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }
        return true
    }
    
    
    // Api Calling
    
    func postServiceWithApiType(parameters:AnyObject,type:CardServiceType){
        var url:(String)?
        if type ==  .AddCardService{
            url = "\(baseUrl)payment/save_card"
        }
        else if type == .GetAllCards{
            url = "\(baseUrl)payment/get_user_cards"
        }
        else if type == .DeleteCard{
            url = "\(baseUrl)payment/delete_card"
        }
        else if type == .SetAsDefaultCard{
            url = "\(baseUrl)payment/set_default_card"
        }
        Alamofire.request(.POST,url!, parameters: parameters as? [String : AnyObject], headers:nil)
            .validate()
            .responseJSON {response in
                self.removeLoadingIndicator()
                switch response.result{
                case .Success:
                    if let val = response.result.value {
                        print(val)
                        // print("JSON: \(JSON)")
                        if(type == .GetAllCards){
                            if val["data"] is  NSArray {
                                print("NSArray")
                                self.cardsArray = val["data"] as! NSArray
                                self.cardsCollectionView.reloadData()
                                print(self.cardsArray)
                            }
                            if val["data"] is String{
                                self.cardsArray = []
                                self.cardsCollectionView.reloadData()
                                  //UtilityMethods.showAlert(val["data"] as! String, tilte: "GoValet", presentVC: self)
                            }
                            
                        }
                        else if(type == .AddCardService){
                            
                            if val["data"] is String{
                                self.clearAllTextFields()
                                self.getAllCards()
                                UtilityMethods.showAlert(val["data"] as! String, tilte: "GoValet", presentVC: self)
                                
                            }
                            else if val["error"] is String{
                                UtilityMethods.showAlert(val["error"] as! String, tilte: "Warning!".localized, presentVC: self)
                            }
                        }
                        else if(type == .DeleteCard){
                            
                            if val["data"] is String{
                                self.getAllCards()
                                UtilityMethods.showAlert(val["data"] as! String, tilte: "GoValet", presentVC: self)
                                
                            }
                            else if val["error"] is String{
                                UtilityMethods.showAlert(val["error"] as! String, tilte: "Warning!".localized, presentVC: self)
                            }
                        }
                        else if(type == .SetAsDefaultCard){
                            
                            if val["data"] is String{
                                self.getAllCards()
                                UtilityMethods.showAlert(val["data"] as! String, tilte: "GoValet", presentVC: self)
                                
                            }
                            else if val["error"] is String{
                                UtilityMethods.showAlert(val["error"] as! String, tilte: "Warning!".localized, presentVC: self)
                            }
                        }
                    }
                case .Failure(let error):
                    if let data = response.data, let utf8Text = String.init(data: data, encoding: NSUTF8StringEncoding) {
                        print("Data: \(utf8Text)")
                    }
                    
                }
        }
    }
    
    func clearAllTextFields(){
        self.firstNameTF.text = ""
        self.lastNameTF.text = ""
        self.cardNoTF.text = ""
        self.expiryMonthTF.text = ""
        self.expiryYearTF.text = ""
        self.cvvTF.text = ""
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

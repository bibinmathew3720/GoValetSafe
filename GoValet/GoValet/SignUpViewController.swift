//
//  SignUpViewController.swift
//  Priza
//
//  Created by Ajeesh T S on 11/10/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AJCountryPicker
import DatePickerDialog
import TOCropViewController
import DKImagePickerController
import MICountryPicker


extension SignUpViewController: WebServiceTaskManagerProtocol,AJCountryPickerDelegate,MICountryPickerDelegate {
    
    
    func countryPicker(picker: MICountryPicker, didSelectCountryWithName name: String, code: String){
    
    }
    
    func countryPicker(picker: MICountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String,image:UIImage?){
        self.coundryCodeLbl.text = dialCode
        if image != nil{
            self.flagImageView.image = image
        }
        picker.navigationController?.popViewControllerAnimated(true)
    }

    
   
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        self.removeLoadingIndicator()
        
        if response.error != nil{
            let errmsg : String = response.error! as String
            self.showAlert("Warning!".localized, message: errmsg)
            return
        }
        if response.data == nil{
            
        }else{
            self.showVerfiyEmailAlert()
//            self.navigationController?.popViewControllerAnimated(false)
//            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let navViewController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeVC") as! UINavigationController
//            UIApplication.sharedApplication().keyWindow?.rootViewController = navViewController;
        }
    }
    
    func ajCountryPicker(picker: AJCountryPicker, didSelectCountryWithName name: String, code: String) {
    
    }
    
    
    func ajCountryPicker(picker: AJCountryPicker, didSelectCountryWithName name: String, code: String, dialCode: String, flag: UIImage?){
        self.coundryCodeLbl.text = dialCode
        if flag != nil{
            self.flagImageView.image = flag
        }
        
    }

    func showVerfiyEmailAlert(){
        let alerController = UIAlertController(title: "", message: "You have been registered successfully, please Verfiy your Email".localized, preferredStyle: .Alert)
        alerController.addAction(UIAlertAction(title: "Ok".localized, style: .Default, handler: {(action:UIAlertAction) in
            let paymentVC = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentVC") as! PaymentViewController
            paymentVC.isSignupFlow = true
            UserInfo.currentUser()?.password = self.passwdTextFld.text
//            UserInfo.currentUser()?.save()
            self.navigationController?.pushViewController(paymentVC, animated: true)

        }));
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Destructive, handler: nil)
//        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
    }
}


class SignUpViewController: UIViewController,TOCropViewControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var fNameTextFld : CustomTextField!
    @IBOutlet weak var lNameTextFld : CustomTextField!
    @IBOutlet weak var emailTextFld : CustomTextField!
    @IBOutlet weak var passwdTextFld : CustomTextField!
    @IBOutlet weak var confirmPasswdTextFld : CustomTextField!
    @IBOutlet weak var dobBtn : UIButton!
    @IBOutlet weak var coundryCodeLbl : UILabel!
    @IBOutlet weak var termsLbl : UILabel!

    @IBOutlet weak var flagImageView : UIImageView!
    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var mobileNumber : UITextField!
    @IBOutlet weak var mobileNumberContainerView : UIView!
    private var isImageChanged = false
    var assets: [DKAsset]?
    var dobApiFormat = ""
    var isEdited = false


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.hidden = false
        self.title = "SIGN UP"
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "SignUpViewController.back(_:)")
        self.navigationItem.leftBarButtonItem = newBackButton

        let myString: String = "By Clicking Confirm You Agree To Go Valet Terms Of Use And Privacy Policy.".localized
        var myMutableString = NSMutableAttributedString()
        myMutableString = NSMutableAttributedString(string: myString, attributes: [NSFontAttributeName:UIFont.systemFontOfSize(9)])
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.02, green:0.62, blue:0.65, alpha:1), range: NSRange(location:42,length:12))
        myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red:0.02, green:0.62, blue:0.65, alpha:1), range: NSRange(location:58,length:16))
        
        myMutableString.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location:42,length:12))
        myMutableString.addAttribute(NSUnderlineStyleAttributeName , value: NSUnderlineStyle.StyleSingle.rawValue, range: NSRange(location:59,length:15))


        termsLbl.attributedText = myMutableString

        emailTextFld.roundCorner()
        passwdTextFld.roundCorner()
        confirmPasswdTextFld.roundCorner()
        fNameTextFld.roundCornerWithvalue(2.0)
        lNameTextFld.roundCornerWithvalue(2.0)
        mobileNumberContainerView.roundCornerValue(3.0)
        dobBtn.roundCornerTheme()
        profileImageView.layer.cornerRadius = 45.0
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        var image = UIImage(named: "logoSmall")
        image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
//        var gimage = UIImage(named: "gradiant")
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(patternImage: UIImage(named: "gradiant")!)]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]

        self.navigationController!.navigationBar.tintColor =  UIColor(patternImage: UIImage(named: "gradiant")!)


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back(sender: UIBarButtonItem) {
        if isEdited{
            let alerController = UIAlertController(title: "", message: "Are you sure you want to cancel the update?", preferredStyle: .Alert)
            alerController.addAction(UIAlertAction(title: "Ok".localized, style: .Destructive, handler: {(action:UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }));
            let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
            alerController.addAction(cancelAction)
            presentViewController(alerController, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
        
    }

    
    
    
    @IBAction func registerButtonClicked(){
        
    }
    
    @IBAction func counrySelectButtonClicked(){
        
        let cpicker = MICountryPicker()
        navigationController?.pushViewController(cpicker, animated: true)
        cpicker.navigationController?.navigationBar.backgroundColor = self.navigationController?.navigationBar.backgroundColor
        cpicker.delegate = self
        
        // Optionally, set this to display the country calling codes after the names
        cpicker.showCallingCodes = true
        
        return
      
    }

    
    @IBAction func dobBtnTapped() {
//        DatePickerDialog().show("") { (date) in
//            self.dobBtn.setTitle("\(date)", forState: .Normal)
//        }
        
        DatePickerDialog().show("", doneButtonTitle: "Done", cancelButtonTitle: "Cancel".localized, defaultDate: NSDate(), minimumDate: nil, maximumDate: NSDate(), datePickerMode: .Date) { (date) in
            if date != nil{
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let dateStr =  dateFormatter.stringFromDate(date!)
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.dobApiFormat = dateFormatter.stringFromDate(date!)
                self.dobBtn.setTitle("\(dateStr)", forState: .Normal)
            }
        }
        
//        DatePickerDialog().show("DatePicker", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
//            (date) -> Void in
//            self.dobBtn.setTitle("\(date)", forState: .Normal)
//        }
    }
    
    @IBAction func signUpButtonClicked(){
        if isValidateCredential() == true{
            self.addLoaingIndicator()
            let serviceManager = LoginServiceManager()
            let email = emailTextFld.text?.trimSpace()
            let psswd = passwdTextFld.text?.trimSpace()
            let fname = fNameTextFld.text?.trimSpace()
            let lname = lNameTextFld.text?.trimSpace()
            let mobile = mobileNumber.text?.trimSpace()
            let cCode = coundryCodeLbl.text?.trimSpace()
            let dob = dobApiFormat
            if isImageChanged == true{
                serviceManager.signUp(email!, passwd: psswd!, fname: fname!, lname: lname!, mobile: mobile!, countryCode: cCode!, dob: dob,profileImage:self.profileImageView.image)
            }else{
                serviceManager.signUp(email!, passwd: psswd!, fname: fname!, lname: lname!, mobile: mobile!, countryCode: cCode!, dob: dob,profileImage:nil)
            }
            serviceManager.managerDelegate = self
        }
        
    }
    
    @IBAction func profileImageButtonClicked(){
        showImagePicker()
    }
    
    @IBAction func closeButtonClicked(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func isValidateCredential() -> Bool{
        if fNameTextFld.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter First Name", tilte: "Warning!".localized, presentVC: self)
            return false
        }
        if lNameTextFld.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Last Name", tilte: "Warning!".localized, presentVC: self)
            return false
        }
        if emailTextFld.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Email".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }else{
            if Validator.isValidEmail(emailTextFld.text!) == false{
                UtilityMethods.showAlert("Please Enter Valid Email".localized, tilte: "Warning!".localized, presentVC: self)
                return false
            }
        }

        if mobileNumber.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Mobile Number", tilte: "Warning!".localized, presentVC: self)
            return false
        }
        
        if coundryCodeLbl.text?.isBlank == true {
            UtilityMethods.showAlert("Please Select Country Code", tilte: "Warning!".localized, presentVC: self)
            return false
        }
        if passwdTextFld.text?.isBlank == true{
            UtilityMethods.showAlert("Please Enter Password", tilte: "Warning!".localized, presentVC: self)
            return false
        }else{
            if Validator.isValidPassword(passwdTextFld.text!){
            }else{
                UtilityMethods.showAlert("Password must contain at least 1 capital and 1 number and minimum 6 characters", tilte: "Warning!".localized, presentVC: self)
                return false
            }
        }
        if passwdTextFld.text == confirmPasswdTextFld.text {
            return true
        }else{
            UtilityMethods.showAlert("Password Mismatch", tilte: "Warning!".localized, presentVC: self)
            return false
        }
    }
    
    func showImagePicker(){
        let pickerController = DKImagePickerController()
        //        pickerController.maxSelectableCount = 1
        pickerController.singleSelect = true
        pickerController.showsEmptyAlbums = false
        pickerController.showsCancelButton = true
        self.assets = nil
        pickerController.defaultSelectedAssets = self.assets
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            self.assets = assets
            //            print("didSelectAssets")
            //            print(assets)
            let asset = self.assets![0]
            asset.fetchOriginalImageWithCompleteBlock({ (image, info) -> Void in
                self.showCropViewController(image!)
            })
        }
        self.presentViewController(pickerController, animated: true) {
            let navigationBarAppearace = UINavigationBar.appearance()
//            navigationBarAppearace.tintColor =  UIColor.blackColor()
//            navigationBarAppearace.barTintColor = UIColor(red:0.13, green:0.14, blue:0.14, alpha:1)
            navigationBarAppearace.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont.systemFontOfSize(16)
            ]
        }
    }
    
    func showCropViewController(image:UIImage){
        let cropViewController = TOCropViewController.init(image:image)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.setAspectRatioPreset(.PresetSquare, animated: true)
        self.presentViewController(cropViewController, animated: true, completion: nil)
    }
    
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int)
    {
        cropViewController.dismissViewControllerAnimated(true) { () -> Void in
            self.profileImageView.image = image
            self.isImageChanged = true
        }
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didFinishCancelled cancelled: Bool)
    {
        cropViewController.dismissViewControllerAnimated(true) { () -> Void in  }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        isEdited = true
        return true
    }

}

//
//  LoginViewController.swift
//  Priza
//
//  Created by Ajeesh T S on 10/10/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift
import IQKeyboardManagerSwift

var isRemberMe = false


extension LoginViewController: WebServiceTaskManagerProtocol,UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField.tag == 0{
            passwdTextFld.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        return true
    }
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        self.removeLoadingIndicator()
        if response.error != nil{
            let errmsg : String = response.error! as String
            if errmsg == "Please check your email"{
                self.showResendConfirmAlert()
            }else{
                self.showAlert("Warning!".localized.localized, message: errmsg)
            }
            return
        }
        if response.data == nil{
        
        }else{
            if self.isResendVerficationApiCal == false{
                callingDeviceTokenApi()
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if UserInfo.currentUser()?.userType == "valet_manager"{
                    let navViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MangerHomeNav") as! UINavigationController
                    let leftSideMenuVC = mainStoryboard.instantiateViewControllerWithIdentifier("SideMenuVC") as! SideMenuListViewController
//                    let slideMenuController = SlideMenuController(mainViewController: navViewController, leftMenuViewController: leftSideMenuVC)
                    
                    let currentLanguage = NSLocale.preferredLanguages()[0]
                    if currentLanguage == "ar-US"{
                        let slideMenuController = SlideMenuController(mainViewController: navViewController, rightMenuViewController: leftSideMenuVC)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
                    }else{
                        let slideMenuController = SlideMenuController(mainViewController: navViewController, leftMenuViewController: leftSideMenuVC)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController

                    }

                    
                }else{
                    UserInfo.currentUser()?.password = passwdTextFld.text
                    if isRemberMe == true{
                        UserInfo.currentUser()?.save()
                    }
                    let navViewController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeVC") as! UINavigationController
                    let leftSideMenuVC = mainStoryboard.instantiateViewControllerWithIdentifier("SideMenuVC") as! SideMenuListViewController
//                    let slideMenuController = SlideMenuController(mainViewController: navViewController, leftMenuViewController: leftSideMenuVC)
                    
                    let currentLanguage = NSLocale.preferredLanguages()[0]
                    if currentLanguage == "ar-US"{
                        let slideMenuController = SlideMenuController(mainViewController: navViewController, rightMenuViewController: leftSideMenuVC)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
                    }else{
                        let slideMenuController = SlideMenuController(mainViewController: navViewController, leftMenuViewController: leftSideMenuVC)
                        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
                        
                    }
//                    UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
                }
            }
        }
    }
}

func callingDeviceTokenApi(){
    
    let tokenString:String =  NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken") as? String ?? ""
    let serviceManger = LoginServiceManager()
    serviceManger.sendDeviceToken(tokenString,deviceId:tokenString)
}

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextFld : CustomTextField!
    @IBOutlet weak var passwdTextFld : CustomTextField!
    @IBOutlet weak var loginBtn : UIButton!
    @IBOutlet weak var signUpBtn : UIButton!
    var manager: OneShotLocationManager?
    

    var isResendVerficationApiCal = false
    var isLocationDenied = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextFld.roundCorner()
        passwdTextFld.roundCorner()
        self.getUserLocation()
//        emailTextFld.text = "ajeeshts.sm@gmail.com"
//        passwdTextFld.text = "qwertyQ1"
        
//        emailTextFld.text = "aswin@qubicle.me"
//        passwdTextFld.text = "123456"

//        emailTextFld.text = "test@hil.com"
//        passwdTextFld.text = "Qwerty1"
        emailTextFld.text = ""
        passwdTextFld.text = ""

        // Do any additional setup after loading the view.
    }

    func getUserLocation(){
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let user_lat = String(format: "%f", loc.coordinate.latitude)
                let user_long = String(format: "%f", loc.coordinate.longitude)
                NSUserDefaults.standardUserDefaults().setObject(user_lat, forKey: "lattiutde")
                NSUserDefaults.standardUserDefaults().setObject(user_long, forKey: "longitude")
//                self.getHotelListFromService(user_lat, longitude: user_long)
            }else{
                //self.isLocationDenied = true
            }
            self.manager = nil
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func showLocationDeniedAlert(){
        let alert = UIAlertController(title: "GoValet", message: "GPS access is restricted. In order to use tracking, please enable GPS in the Settigs app under Privacy, Location Services.".localized, preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(UIAlertAction(title: "Go to Settings now".localized, style: UIAlertActionStyle.Default, handler: { (alert: UIAlertAction!) in
            print("")
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }))
        presentViewController(alert, animated: true, completion: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.hidden = true
        IQKeyboardManager.sharedManager().enable = false
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        self.navigationController?.navigationBar.hidden = false
//    }

    @IBAction func loginButtonClicked(){
        if isValidateCredential() == true{
            manager = OneShotLocationManager()
            manager!.fetchWithCompletion {location, error in
                // fetch location or an error
                if let loc = location {
                    print(location)
                    let user_lat = String(format: "%f", loc.coordinate.latitude)
                    let user_long = String(format: "%f", loc.coordinate.longitude)
                    NSUserDefaults.standardUserDefaults().setObject(user_lat, forKey: "lattiutde")
                    NSUserDefaults.standardUserDefaults().setObject(user_long, forKey: "longitude")
                    self.addLoaingIndicator()
                    self.isResendVerficationApiCal = false
                    let serviceManager = LoginServiceManager()
                    serviceManager.managerDelegate = self
                    serviceManager.login(self.emailTextFld.text!, passwd: self.passwdTextFld.text!)
                }else{
                    self.isLocationDenied = true
                    self.showLocationDeniedAlert()
//                    let serviceManager = LoginServiceManager()
//                    serviceManager.managerDelegate = self
//                    serviceManager.login(self.emailTextFld.text!, passwd: self.passwdTextFld.text!)

                }
                self.manager = nil
            }
        }
    }
    
    @IBAction func rememberMeButtonClicked(sender: UIButton){
        if sender.tag == 0{
            isRemberMe = true
            let image = UIImage(named:"tikimage")
//            image?.maskWithColor(UIColor(red:0, green:0.51, blue:0.58, alpha:1))
            sender.setImage(image, forState: .Normal)
            sender.tag = 1
        }else{
            isRemberMe = false
            sender.setImage(UIImage(named:"radioBtn"), forState: .Normal)
            sender.tag = 0
        }
        
    }
    
    @IBAction func forgotButtonClicked(){
        UIApplication.sharedApplication().openURL(NSURL(string: "http://govalet.me/forgotpassword")!)
    }
    
    @IBAction func signUpButtonClicked(){
        let signUpVC = self.storyboard?.instantiateViewControllerWithIdentifier("SignUpVC") as! SignUpViewController
//        let navCtrl = UINavigationController.init(rootViewController: signUpVC)
        self.navigationController?.pushViewController(signUpVC, animated: true)
//        self.presentViewController(signUpVC, animated: true, completion: nil)
    }
    
    
    func isValidateCredential() -> Bool{
        var status = self.isValidEmail()
        if status == false{
            return status
        }
        if passwdTextFld.text?.isBlank == true{
            UtilityMethods.showAlert("Please Enter Password".localized, tilte: "Warning!".localized, presentVC: self)
            status = false
        }else{
            status = true
        }
        return status
    }
    
  /*
    func isValidateCredential() -> Bool{
        self.isValidEmail()
        
        if passwdTextFld.text?.isBlank == true{
            UtilityMethods.showAlert("Please Enter Password", tilte: "Warning!".localized, presentVC: self)
            return false
        }else{
            if self.validatePassword(passwdTextFld.text!){
                return true
                
            }else{
                UtilityMethods.showAlert("Please Enter Email", tilte: "Warning!".localized, presentVC: self)
                return false
                print("false")
            }
        }
        return true
    }
   */
    
    func validatePassword(password: String) -> Bool
    {
        let regularExpression = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}$"
        
        let passwordValidation = NSPredicate.init(format: "SELF MATCHES %@", regularExpression)
        
        return passwordValidation.evaluateWithObject(password)
    }
    
    
    func isValidEmail() -> Bool{
        if emailTextFld.text?.isBlank == true {
            UtilityMethods.showAlert("Please Enter Email".localized, tilte: "Warning!".localized, presentVC: self)
            return false
        }else{
            if Validator.isValidEmail(emailTextFld.text!) == false{
                UtilityMethods.showAlert("Please Enter Valid Email".localized, tilte: "Warning!".localized, presentVC: self)
                return false
            }else{
                return true
            }
        }
    }
    
    func showResendConfirmAlert(){
        let alerController = UIAlertController(title: "", message: "Please verify your email address".localized, preferredStyle: .Alert)
        alerController.addAction(UIAlertAction(title: "Resend".localized, style: .Default, handler: {(action:UIAlertAction) in
            self.callResendVerificationAPI()
        }));
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Destructive, handler: nil)
        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
    }
    
    
    func callResendVerificationAPI(){
        if self.isValidEmail() == true{
            isResendVerficationApiCal = true
            self.addLoaingIndicator()
            let serviceManager = LoginServiceManager()
            serviceManager.managerDelegate = self
            serviceManager.resendVerfication(emailTextFld.text!)
        }
    }
    
    func callForgotPasswordAPI(){
        if self.isValidEmail() == true{
            isResendVerficationApiCal = true
            self.addLoaingIndicator()
            let serviceManager = LoginServiceManager()
            serviceManager.managerDelegate = self
            serviceManager.resendVerfication(emailTextFld.text!)
        }
    }

}

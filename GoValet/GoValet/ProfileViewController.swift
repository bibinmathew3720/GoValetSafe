

//
//  ProfileViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 05/01/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var userNameLbl : UILabel!
    @IBOutlet weak var editBtn : UIButton!
    @IBOutlet weak var languageBtn : UIButton!
    @IBOutlet weak var signoutBtn : UIButton!
    @IBOutlet  var languageBtnConstrain : NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLogo()
        self.title = "SETTINGS".localized
        self.changeNavTitleColor()
        if UserInfo.currentUser()?.userType == "valet_manager"{
            editBtn.hidden = true
            languageBtnConstrain.constant = 0
        }
        profileImageView.layer.cornerRadius = 50.0
        profileImageView.clipsToBounds = true
        editBtn.roundCornerValue(3.0)
        languageBtn.roundCornerValue(3.0)
        signoutBtn.roundCornerValue(3.0)
        self.showUserInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showUserInfo(){
        if let userName = UserInfo.currentUser()?.userName{
            let uname : String = userName
            userNameLbl.text = uname
        }
        
        if let imageUrl = UserInfo.currentUser()?.profileImage{
//            profileImageView.sd_setImageWithURL(NSURL(string:(imageUrl)))
            profileImageView.sd_setImageWithURL(NSURL(string:(imageUrl)), placeholderImage: UIImage(named: "user"))
        }else{
            profileImageView.image = UIImage(named: "user")
        }
    }

    
    @IBAction func logoutBtnclicked(){
        showLogoutConfirmAlert()
    }
    
    @IBAction func editBtnclicked(){
        self.showPasswordConfirmAlert()
    }
    
    @IBAction func languageBtnclicked(){
        self.showLanguageOption()
//        let currentLanguage = NSLocale.preferredLanguages()[0]
//        
//        if currentLanguage == "ar-US"{
//            NSUserDefaults.standardUserDefaults().setObject(["en", "ar-US"], forKey: "AppleLanguages")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }else{
//            NSUserDefaults.standardUserDefaults().setObject(["ar-US", "en"], forKey: "AppleLanguages")
//            NSUserDefaults.standardUserDefaults().synchronize()
//        }
//        self.showAlert("Language Change", message: "Please restart the app to change the language")

    }
    
    func showLanguageOption(){
        let alerController = UIAlertController(title: "", message: "Change Language".localized, preferredStyle: .ActionSheet)
        alerController.addAction(UIAlertAction(title: "English".localized, style: .Default, handler: {(action:UIAlertAction) in
            NSUserDefaults.standardUserDefaults().setObject(["en", "ar-US"], forKey: "AppleLanguages")
            NSUserDefaults.standardUserDefaults().synchronize()
            UIView.appearance().semanticContentAttribute = .ForceLeftToRight
            self.showAlert("Language Change".localized, message: "Please restart the app to change the language".localized)

        }));
        alerController.addAction(UIAlertAction(title: "Arabic".localized, style: .Default, handler: {(action:UIAlertAction) in
            NSUserDefaults.standardUserDefaults().setObject(["ar-US", "en"], forKey: "AppleLanguages")
            NSUserDefaults.standardUserDefaults().synchronize()
            UIView.appearance().semanticContentAttribute = .ForceRightToLeft
            self.showAlert("Language Change".localized, message: "Please restart the app to change the language".localized)

        }));
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
    }
    
    
    func showPasswordConfirmAlert(){
        let alertController = UIAlertController(title: "", message: "Please enter your Password".localized, preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Confirm".localized, style: .Default) { (_) in
            if let field : UITextField = alertController.textFields![0] {
                if field.text?.isBlank == true {
                    UtilityMethods.showAlert("Wrong Password!".localized, tilte: "Warning!".localized, presentVC: self)
                }else{
                    if UserInfo.currentUser()?.password != nil{
                        let passwd  : String = (UserInfo.currentUser()?.password)!
                        if field.text == passwd{
                            let profilEditVC = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileEditVC") as! ProfileEditViewController
                            self.navigationController?.pushViewController(profilEditVC, animated: true)
                        }else{
                            UtilityMethods.showAlert("Wrong Password!".localized, tilte: "Warning!".localized, presentVC: self)
                        }
                        
                    }
                }
            }else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password".localized
            textField.secureTextEntry = true
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
   
    
    func showLogoutConfirmAlert() {
        let alerController = UIAlertController(title: "", message: "Are you sure you want to log out?".localized, preferredStyle: .ActionSheet)
        alerController.addAction(UIAlertAction(title: "Log Out".localized, style: .Destructive, handler: {(action:UIAlertAction) in
            self.logout()
        }));
        let cancelAction = UIAlertAction(title: "Cancel".localized , style: .Cancel, handler: nil)
        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
    }
    
    func logout(){
        UserInfo.currentUser()?.clearSession()
        let loginManager = LoginServiceManager()
        loginManager.loginOut()
        self.dismissViewControllerAnimated(false, completion: nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginNav")
        UIApplication.sharedApplication().keyWindow?.rootViewController = viewController;
    }

}

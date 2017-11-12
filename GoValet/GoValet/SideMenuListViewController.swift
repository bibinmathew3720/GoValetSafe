//
//  SideMenuListViewController.swift
//  Priza
//
//  Created by Ajeesh T S on 10/10/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

extension SideMenuListViewController :WebServiceTaskManagerProtocol{
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        if response.data == nil{
        }else{
//            if let products = response.data?.responseModel as? [Product] {
//                productList = products
//                self.productCollectionView.reloadData()
//            }
        }
    }
}

class SideMenuListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var listTableVew : UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.listTableVew.tableFooterView = UIView()
//        self.getCatageoryList()

        // Do any additional setup after loading the view.
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if UserInfo.currentUser()?.userType == "valet_manager"{
            return 4
        }else{
            return 6
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        }else{
            return 70
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell!
        
        if indexPath.row == 0{
            let userProfileCell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! UserProfileCell
            userProfileCell.userNameLbl?.font = UIFont.systemFontOfSize(13.0)
            if UserInfo.currentUser()?.userType == "valet_manager"{
                userProfileCell.userNameLbl.text = "Manager"
            }else{
                userProfileCell.showUserInfo()
            }
            userProfileCell.showUserInfo()
            cell = userProfileCell
        }else{
           let menuCell = tableView.dequeueReusableCellWithIdentifier("MenuItemCell", forIndexPath: indexPath) as! SideMenuCell
            menuCell.menuTitleLbl?.font = UIFont.systemFontOfSize(16.0)

            switch indexPath.row {
            case 1:
                if UserInfo.currentUser()?.userType == "valet_manager"{
                    menuCell.menuTitleLbl.text = "Shift Staff Number".localized
                    menuCell.menuImageView.image = UIImage(named:"ShiftSetting")
                }else{
                    menuCell.menuTitleLbl.text = "Subscription".localized
                    menuCell.menuImageView.image = UIImage(named:"Payments")
                }
            case 2:
                if UserInfo.currentUser()?.userType == "valet_manager"{
                    menuCell.menuTitleLbl.text  = "Settings".localized
                    menuCell.menuImageView.image = UIImage(named:"Settings")
                }else{
                    menuCell.menuTitleLbl.text  = "Manage Cards".localized
                    menuCell.menuImageView.image = UIImage(named:"ManageCard")
                }

            case 3:
                if UserInfo.currentUser()?.userType == "valet_manager"{
                    menuCell.menuTitleLbl.text  = "Help".localized
                    menuCell.menuImageView.image = UIImage(named:"Help")
                }else{
                    menuCell.menuTitleLbl.text  = "History".localized
                    menuCell.menuImageView.image = UIImage(named:"History")
                }

            case 4:
                menuCell.menuTitleLbl.text  = "Help".localized
                menuCell.menuImageView.image = UIImage(named:"Help")
            case 5:
                menuCell.menuTitleLbl.text  = "Settings".localized
                menuCell.menuImageView.image = UIImage(named:"Settings")

            default: break
            }
            cell = menuCell
        }
        
       
//        if indexPath.row != 0 {
//            cell.textLabel?.text = titleStr
//            cell.textLabel?.font = UIFont.systemFontOfSize(12.0)
//        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        showCategoryView()
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            var titleStr = ""
            switch indexPath.row {
            case 0: break
                
            case 1:
                if UserInfo.currentUser()?.userType == "valet_manager"{
                    let myDict = ["menu": "2"]
                    NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
                    self.closeMenu()
                }else{
                    var myDict = ["menu": "4"]
                    NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
                    self.closeMenu()
                    //self.showPasswordConfirmAlert()
                }
            case 2:
                    //var myDict = ["menu": "3"]
                    var myDict = ["menu": "5"]
                    if UserInfo.currentUser()?.userType == "valet_manager"{
                        myDict = ["menu": "1"]
                    }
                    NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
                    self.closeMenu()
            case 3:
                if UserInfo.currentUser()?.userType == "valet_manager"{
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://govalet.me/")!)
                }
                else{
                    let myDict = ["menu": "3"]
                    NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
                       self.closeMenu()
                }
//                let myDict = ["menu": "4"]
//                self.dismissViewControllerAnimated(true, completion: nil)
//                NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
            case 4:
                    UIApplication.sharedApplication().openURL(NSURL(string: "http://govalet.me/")!)
            case 5:
                let myDict = ["menu": "1"]
                NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
                self.closeMenu()
            case 6:
                titleStr = "About Us"
            case 7:
                titleStr = "Contact Us"
            case 8:
                titleStr = "Logout".localized
                self.showLogoutConfirmAlert()
            default:
                titleStr = ""
            }
            
        })

    }
    
    func closeMenu(){
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            self.slideMenuController()?.closeRight()
        }else{
            self.slideMenuController()?.closeLeft()
        }
    }
    
    func showPasswordConfirmAlert(){
        let alertController = UIAlertController(title: "", message: "Please enter your Password", preferredStyle: .Alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field : UITextField = alertController.textFields![0] {
                if field.text?.isBlank == true {
                    UtilityMethods.showAlert("Wrong Password!", tilte: "Warning!".localized, presentVC: self)
                }else{
                    if UserInfo.currentUser()?.password != nil{
                        let passwd  : String = (UserInfo.currentUser()?.password)!
                        if field.text == passwd{
                            self.showPaymentScreen()
                        }else{
                            UtilityMethods.showAlert("Wrong Password!", tilte: "Warning!".localized, presentVC: self)
                        }
                    }
                }
            }else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func showPaymentScreen(){
        var myDict = ["menu": "4"]
         if UserInfo.currentUser()?.userType == "valet_manager"{
             myDict = ["menu": "2"]
        }
        
    NSNotificationCenter.defaultCenter().postNotificationName("SideMenuOpenNotification", object:myDict);
        self.closeMenu()
    }
    
    
    func showLogoutConfirmAlert() {
        let alerController = UIAlertController(title: "", message: "Are you sure you want to log out?", preferredStyle: .ActionSheet)
        alerController.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: {(action:UIAlertAction) in
            self.logout()
        }));
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
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

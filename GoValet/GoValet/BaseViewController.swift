//
//  BaseViewController.swift
//  Tastyspots
//
//  Created by Ajeesh T S on 21/12/15.
//  Copyright © 2015 Ajeesh T S. All rights reserved.
//

import UIKit



class BaseViewController: UIViewController  {
    var showAppThemeNavigationBar = false
    var locationButton:UIButton = UIButton()
    var downArrowImage:UIImageView!
    var needToAddLeftSideMenu = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if showAppThemeNavigationBar == true {
            showCustomAppThemeNavigationBar()
        }
        if needToAddLeftSideMenu == true {
//            addRightSideMenu()
        }
       
    }

    func resetRightSideMenu(){
//        addRightSideMenu()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func showCustomAppThemeNavigationBar(){
    
        let profileButton:UIButton = UIButton(type: UIButtonType.Custom)  
        profileButton.addTarget(self, action: Selector("profileButtonClicked"), forControlEvents: UIControlEvents.TouchUpInside)
        let backBtnImg: UIImage = UIImage(named: "Menu")!
        profileButton.setImage(backBtnImg, forState: UIControlState.Normal)
        profileButton.frame = CGRectMake(-30, 0, 25, 45)
        let profileButtonItem:UIBarButtonItem = UIBarButtonItem(customView: profileButton)
        self.navigationItem.leftBarButtonItems  = [profileButtonItem]
    }
    
    
 
    
    func changeLicationTitle(title : String){
        
        let width = title.heightWithConstrainedWidth(30, font: (locationButton.titleLabel?.font)!)
        locationButton.imageEdgeInsets = UIEdgeInsetsMake(3, width + 15, 0,0)

//        heightWithConstrainedWidth()
    }
    
    func profileButtonClicked(){
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            self.slideMenuController()?.openRight()
        }else{
            self.slideMenuController()?.openLeft()
        }
        

//        if let _ = NSUserDefaults.standardUserDefaults().objectForKey("UserToken") as? String {
//            let profileVC  = self.storyboard?.instantiateViewControllerWithIdentifier("UserProfVC") as! UserProfileViewController
//            SideMenuManager.menuRightNavigationController?.viewControllers = [profileVC]
//        }
//        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        
    }
    
    func searchButtonClicked(){
    
    }
    
 
    
    func checkLoginStatus()-> Bool{
        if AppSharedInfo.sharedInstance.isReachableInternet == true{
            if let _ = NSUserDefaults.standardUserDefaults().objectForKey("UserToken") as? String {
                return true
            }else{
                return false
            }
            
        }else{
            UtilityMethods.showNoInternetAlert(self)
            return false
        }
    }
    



}

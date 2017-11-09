//
//  PaymentViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 29/12/16.
//  Copyright © 2016 Ajeesh T S. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

extension UIViewController{
    func addLogo(){
        let logoButton:UIButton = UIButton(type: UIButtonType.Custom)
        let logoImg: UIImage = UIImage(named: "logo")!
        logoButton.setImage(logoImg, forState: UIControlState.Normal)
        logoButton.frame = CGRectMake(0, 0, 35, 35)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoButton)
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.barTintColor = UIColor(red:0.13, green:0.14, blue:0.14, alpha:1)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        self.navigationController?.navigationBar.translucent = true
         self.navigationController?.navigationBar.shadowImage =  UIImage()
        let lineview = UIView.init(frame: CGRectMake(12, (self.navigationController?.navigationBar.frame.size.height)!-1, ((navigationController?.navigationBar.frame.size.width)! - 24), 1))
        lineview.backgroundColor = UIColor(red:0.33, green:0.33, blue:0.33, alpha:1)
        lineview.opaque = true
        navigationController?.navigationBar.addSubview(lineview)

    }
    
    func changeNavTitleColor(){
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(patternImage: UIImage(named: "gradiant")!),NSFontAttributeName: UIFont.systemFontOfSize(16)]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.backItem?.title = " "
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }

}

class PaymentViewController: UIViewController {

    @IBOutlet weak var normalPaymentView : UIView!
    @IBOutlet weak var subscriptionPaymentView : UIView!
    var isNormalPayment = true
    @IBOutlet weak var webView: UIWebView!
    var isSignupFlow = false

    override func viewDidLoad() {
        super.viewDidLoad()
        if isSignupFlow{
            let rightButtonItem = UIBarButtonItem.init(
                title: "Done",
                style: .Done,
                target: self,
                action: "PaymentViewController.rightButtonAction"
            )
            self.navigationItem.rightBarButtonItem = rightButtonItem
            self.navigationItem.setHidesBackButton(true, animated:false)
        }else{
            self.addLogo()
        }
        webView.hidden = true
        normalPaymentView.roundCornerValue(5.0)
        normalPaymentView.layer.borderColor = UIColor(red:0.94, green:0.32, blue:0.14, alpha:1).CGColor
        subscriptionPaymentView.roundCornerValue(5.0)
        self.title = "PAYMENT SUBSCRIPTION".localized
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor(patternImage: UIImage(named: "gradiant")!),NSFontAttributeName: UIFont.systemFontOfSize(13)]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.navigationController?.navigationBar.backItem?.title = " "
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func rightButtonAction(){
        UserInfo.currentUser()?.clearSession()
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let navViewController = mainStoryboard.instantiateViewControllerWithIdentifier("HomeVC") as! UINavigationController
        let leftSideMenuVC = mainStoryboard.instantiateViewControllerWithIdentifier("SideMenuVC") as! SideMenuListViewController
//        let slideMenuController = SlideMenuController(mainViewController: navViewController, leftMenuViewController: leftSideMenuVC)
//        UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
        
        
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            let slideMenuController = SlideMenuController(mainViewController: navViewController, rightMenuViewController: leftSideMenuVC)
            UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
        }else{
            let slideMenuController = SlideMenuController(mainViewController: navViewController, leftMenuViewController: leftSideMenuVC)
            UIApplication.sharedApplication().keyWindow?.rootViewController = slideMenuController
            
        }
        


    }


    @IBAction func normalPaymentBtnClicked(){
        isNormalPayment = true
        normalPaymentView.roundCornerValue(5.0)
        normalPaymentView.layer.borderColor = UIColor(red:0.94, green:0.32, blue:0.14, alpha:1).CGColor
        subscriptionPaymentView.roundCornerValue(5.0)

    }
    
    @IBAction func subscriptionPaymentBtnClicked(){
        isNormalPayment = false
        subscriptionPaymentView.roundCornerValue(5.0)
        subscriptionPaymentView.layer.borderColor = UIColor(red:0.94, green:0.32, blue:0.14, alpha:1).CGColor
        normalPaymentView.roundCornerValue(5.0)
    }
    
    @IBAction func paymentManageBtnClicked(){
        let webviewVC =  self.storyboard?.instantiateViewControllerWithIdentifier("WebViewVC") as! WebViewViewController
        self.navigationController?.pushViewController(webviewVC, animated: true)
    }
    
    @IBAction func getItBtnClicked(){
        webView.hidden = false
//        self.navigationController?.navigationBarHidden = true
        if isNormalPayment{
            payForCart("pay_as_go")
        }else{
            payForCart("1month_subscription")
        }
    }
    
    func payForCart(type:String) {
        
        //payment
        let URLString = "http://govalet.me/subscription/payment"
        var queryString = ""
        
        //        queryString += "amount=\(amount)"
        /*
         switch payment! {
         case .PurchaseCards:
         queryString += "&cards=\(encodedItems())"
         case .PurchasePosters:
         queryString += "&posters=\(encodedItems())"
         case .PurchaseStoreItem:
         queryString += "&order_id=\(orderID!)"
         }
         */
        
        queryString += "&subscription_type=\(type)"
        
        if let accessToken = UserInfo.currentUser()?.token{
            queryString += "&token=\(accessToken)"
            
        }
        
        //        let key = "LOCALIZATION_KEY"
        //        let langID = NSLocalizedString(key, comment: "to get current localization key")
        //        if langID != key {
        //            queryString += "&language=\(langID)"
        //
        //        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: URLString)!)
        request.HTTPBody = queryString.dataUsingEncoding(NSUTF8StringEncoding)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        self.webView.loadRequest(request)
        
    }
    
//    func encodedItems() -> String {
//        do {
//            let jsonData = try NSJSONSerialization.dataWithJSONObject(items!, options: NSJSONWritingOptions.PrettyPrinted)
//            
//            return String(data: jsonData, encoding: NSUTF8StringEncoding)!
//        } catch let error as NSError {
//            print(error)
//        }
//        return ""
//    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool{
        print("shouldStartLoadWithRequest \(request)")
        let urlString = (request.URL?.absoluteString)!
        var success: Bool? = nil
        if urlString == "http://govalet.me/subscription/paypal_success" {
//            NSNotificationCenter.defaultCenter().postNotificationName("ShopingContinueNotification", object:nil)
            self.navigationController?.popViewControllerAnimated(false)
//            self.navigationController?.navigationBarHidden = true
        }
        if urlString.hasSuffix("paypal_failure") {
            success = false
//            self.navigationController?.navigationBarHidden = true
        }
        if let value = success {
            //   delegate?.paymentViewControllerDidCompleted!(value)
        }
        
        return true
    }
    
    func webViewDidStartLoad(webView: UIWebView){
        print("webViewDidStartLoad ");
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        //        webView.frame.size.height = 1
        //        let webSize = webView.sizeThatFits(CGSizeZero)
        //        paymentViewHeight.constant = webSize.height
        //        webView.frame.size = webView.sizeThatFits(CGSizeZero)
        print("webViewDidFinishLoad ");
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print("didFailLoadWithError \(error)");
    }
    
    
    
}



//
//  WebViewViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 16/02/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

class WebViewViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    var url : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationController?.navigationBar.tintColor = UIColor.blueColor()
//        self.navigationController?.navigationBar.backgroundColor = UIColor(red:0.13, green:0.14, blue:0.14, alpha:1)
        self.addLogo()
        self.loadWebview()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadWebview() {
        
        //payment
        let URLString = "https://govalet.me/subscription/listcards"
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
        
//        queryString += "&subscription_type=\(type)"
        
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

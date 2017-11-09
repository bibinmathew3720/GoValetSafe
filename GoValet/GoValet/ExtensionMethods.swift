//
//  ExtensionMethods.swift
//  Baqaala
//
//  Created by Ajeesh T S on 30/07/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit
import MBProgressHUD

extension String {
    var localized: String {
//        let path = NSBundle.mainBundle().pathForResource(lang, ofType: "lproj")
//        let bundle = NSBundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}


class CustomTextField: UITextField {
    let inset: CGFloat = 10
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , inset , inset)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, inset)
    }
}

extension UIViewController {
    
    func showAlert(title: String?, message: String?) {
        let alerController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
        
    }
    
    func showAlertwithTitle(title: String, message: String) {
        let alerController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
    }
    
    func showWarningAlert(message: String){
        self.showAlertwithTitle("Warning!".localized, message: message)
    }
    
    func addLoaingIndicator(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        })

    }
    
    func removeLoadingIndicator(){
        MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    func showErrorAlert(message: String){
        self.showAlertwithTitle("Error!", message: message)
    }
    

    
//    func createProgressHUD() -> MBProgressHUD {
//        let hud = MBProgressHUD(view: view)
//        view.addSubview(hud)
//        hud.dimBackground = true
//        hud.labelText = "Loading..."
//        return hud
//    }
}

class ExtensionMethods: NSObject {

    
}

extension UIView {
    var cornerRadius:CGFloat! {
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
        get {
            return layer.cornerRadius
        }
    }
    
    var borderWidth:CGFloat! {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    var borderColor:UIColor! {
        set {
            layer.borderColor = newValue.CGColor
        }
        get {
            return UIColor(CGColor: layer.borderColor!)
        }
    }
}

extension UIImage {
    func maskWithColor(color: UIColor) -> UIImage? {
        
        let maskImage = self.CGImage
        let width = self.size.width
        let height = self.size.height
        let bounds = CGRectMake(0, 0, width, height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedLast.rawValue)
        let bitmapContext = CGBitmapContextCreate(nil, Int(width), Int(height), 8, 0, colorSpace, bitmapInfo.rawValue) //needs rawValue of bitmapInfo
        
        CGContextClipToMask(bitmapContext, bounds, maskImage)
        CGContextSetFillColorWithColor(bitmapContext, color.CGColor)
        CGContextFillRect(bitmapContext, bounds)
        
        //is it nil?
        if let cImage = CGBitmapContextCreateImage(bitmapContext) {
            let coloredImage = UIImage(CGImage: cImage)
            
            return coloredImage
            
        } else {
            return nil
        } 
    }
}

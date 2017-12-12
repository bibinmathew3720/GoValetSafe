//
//  LoginWebService.swift
//  Priza
//
//  Created by Ajeesh T S on 11/10/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit

class LoginWebService: BaseWebService {
    
    func loginService(email:String, passwd:String){
        parameters = ["email":email,"password":passwd]
        self.url = "\(baseUrl)user/login"
        POST()
    }
    
    func signupService(){
        self.url = "\(baseUrl)user/signup"
//        url = "http://burjalsafacomputers.com/dev/fnb/api/rest/signup"
        POST()
    }
    
    func resendVerficationService(email:String){
        parameters = ["email":email]
        self.url = "\(baseUrl)user/resend_verification"
        POST()
    }
    
    func forgotyPasswordService(email:String){
        parameters = ["email":email]
        self.url = "\(baseUrl)forgotpassword"
        POST()
    }
    
    
    func loginOutService(){
        self.url = "\(baseUrl)user/logout"
        POST()
    }
    
    func sendDeviceTokenService(token:String,deviceId:String){
        let userType:String = (UserInfo.currentUser()?.userType)! as String
        var finalCustomerType:String = ""
        if(userType == "valet_manager"){
            finalCustomerType = "manager"
        }
        else{
            finalCustomerType = "customer"
        }
        
        parameters = ["gcm_ios_id":deviceId,"user_type":finalCustomerType]
        print(parameters)
        self.url = "\(baseUrl)user/update_gcm_ios_id"
        POST()
    }
    
    

}

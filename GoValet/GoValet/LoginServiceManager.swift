//
//  LoginServiceManager.swift
//  Priza
//
//  Created by Ajeesh T S on 11/10/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit

enum LoginServiceType {
    case Login
    case Signup
    case Default
}

extension LoginServiceManager : BaseServiceDelegates  {
    
    
    func didSuccessfullyReceiveData(response:RestResponse?){
        let responseData = response!.response!
        if let errorMsg = responseData["error"].string{
            managerDelegate?.didFinishTask(from: self, response: (data: response, error: errorMsg))
            return
        }
        if currentServiceType == .Login || currentServiceType == .Signup{
            UserInfo.createSessionWith(responseData)
            if isRemberMe == true{
                if UserInfo.currentUser()?.userType != "valet_manager"{
                    UserInfo.currentUser()?.save()
                }
            }
        }
        managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
    }

    func didFailedToReceiveData(response:RestResponse?){
        managerDelegate?.didFinishTask(from: self, response: (data: nil, error: nil))
    }

}
        

class LoginServiceManager: WebServiceTaskManager {
    
    var currentServiceType = LoginServiceType.Default
    func login(email:String, passwd:String){
        currentServiceType = .Login
        let loginService = LoginWebService()
        loginService.delegate = self
        loginService.loginService(email,passwd:passwd)
    }
    
    func resendVerfication(email:String){
        let loginService = LoginWebService()
        loginService.delegate = self
        loginService.resendVerficationService(email)
    }
    
    func forgotPassword(email:String){
        let loginService = LoginWebService()
        loginService.delegate = self
        loginService.forgotyPasswordService(email)
    }
    
    func sendDeviceToken(deviceToken:String,deviceId:String){
        let loginService = LoginWebService()
//        loginService.delegate = self
        loginService.sendDeviceTokenService(deviceToken,deviceId:deviceId)
    }
    
    func signUp(email:String, passwd:String,fname:String, lname:String,mobile:String, countryCode:String,dob:String,profileImage: UIImage?){
        currentServiceType = .Signup
        let loginService = LoginWebService()
        loginService.delegate = self
        var params = [String: AnyObject]()
        params["first_name"] = fname
        params["last_name"] = lname
        params["email"] = email
        params["country_code"] = countryCode
        params["mobile"] = mobile
        params["password"] = passwd
        if dob.isBlank == false{
            params["dob"] = dob
        }
        loginService.parameters = params
        if let image = profileImage {
            let data = UIImageJPEGRepresentation(image, 0.8)!
            let multipartData = MultipartData(data: data, name: "image", fileName: "image.jpg", mimeType: "image/jpeg")
            loginService.uploadData = [multipartData]
        }

        loginService.signupService()
    }
    
    func signUpTest(email:String, passwd:String,fname:String, lname:String,mobile:String, countryCode:String,dob:String,profileImage: UIImage?){
        currentServiceType = .Signup
        let loginService = LoginWebService()
        loginService.delegate = self
        var params = [String: AnyObject]()
        params["planId"] = "1"
        params["custType"] = "0"
        params["prefix"] = "Mr"
        params["firstName"] = "Test"
        params["lastName"] = "User"
        params["email"] = "ajeeshts.sm@gmail.com"
        params["password"] = "sim123"
        params["country"] = "IN"
        params["displayName"] = "TESTUSER"
        params["contactNumber"] = "8086644704"
        params["company"] = "company1"
        params["companyAddress"] = "companyadd"
        params["deviceType"] = "1"
        params["deviceToken"] = "12434324"
        loginService.parameters = params
        if let image = profileImage {
            let data = UIImageJPEGRepresentation(image, 0.8)!
            let multipartData = MultipartData(data: data, name: "trade_certificate", fileName: "image.jpg", mimeType: "image/jpeg")
            let multipartData2 = MultipartData(data: data, name: "identity_proof", fileName: "image.jpg", mimeType: "image/jpeg")
            let multipartData3 = MultipartData(data: data, name: "address_proof", fileName: "image.jpg", mimeType: "image/jpeg")
            loginService.uploadData = [multipartData,multipartData2,multipartData3]
        }
        
        loginService.signupService()
    }

    
    
    func loginOut(){
        let loginService = LoginWebService()
        loginService.delegate = self
        var params = [String: AnyObject]()
        if let token = UserInfo.currentUser()?.token{
            params["token"] = token
        }else{
        }
        loginService.parameters = params
        loginService.loginOutService()
    }


}

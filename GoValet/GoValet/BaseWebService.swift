//
//  BaseWebService.swift
//  Tastyspots
//
//  Created by Ajeesh T S on 23/12/15.
//  Copyright © 2015 Ajeesh T S. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

var baseUrl = "http://govalet.me/"


class RestResponse : NSObject {
    var response : JSON?
    var responseModel : AnyObject?
    var responseCode : Int?
    var requestCode : Int?
    var responseHttpCode : Int?
    var responseDetail : AnyObject?
    var error : NSError?
    var paginationIndex : NSMutableString?
    var requestData : AnyObject?
    var successMessage : String?

    
}

class MultipartData: NSObject {
    var data: NSData
    var name: String
    var fileName: String
    var mimeType: String
    init(data: NSData, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
        
    }
}

@objc protocol BaseServiceDelegates {
    //the service call was successful and the data is passed to the manager
    optional func didSuccessfullyReceiveData(response:RestResponse?)
    
    //the service call was failed and the error message to be shown is
    //fetched and returned to the manager.
    optional func didFailedToReceiveData(response:RestResponse?)
    
    optional func imageUploadPrograss(prograssValue : Float)
    
}

enum WebServiceType {
    case None
    case FoodSpotReviewImageUploading
}

class BaseWebService: NSObject {
    var currentServiceType = WebServiceType.None
    var delegate : BaseServiceDelegates?
    var url: String?
    var parameters = [String: AnyObject]()
    var uploadData: [MultipartData]?
    var header:[String : String]?
    var requestInfo : [String:String]?

    func GET(){
        if let token = UserInfo.currentUser()?.token{
            let authHeader =  ["token": token]
            header = authHeader
        }else{
            header = nil
        }

       Alamofire.request(.GET,url!, parameters: parameters, headers:header)
            .validate()
            .responseJSON {response in
            
            switch response.result{
            
            case .Success:
                if let val = response.result.value {
                    // print("JSON: \(JSON)")
                   let json = JSON(val)
//                    print("JSON: \(json)")
                    self.successWithResponse(json)
                    
                }
            case .Failure(let error):
                self.failureWithError(error)

            }
        }
    }

    
    func AuthGET(){
        if let token = UserInfo.currentUser()?.token{
            let authHeader =  ["token": token]
            header = authHeader
        }else{
            header = nil
        }
        
        Alamofire.request(.GET,url!, parameters: parameters, headers:header)
            .validate()
            .responseJSON {response in
                
                switch response.result{
                    
                case .Success:
                    if let val = response.result.value {
                        // print("JSON: \(JSON)")
                        let json = JSON(val)
                        //                    print("JSON: \(json)")
                        self.successWithResponse(json)
                        
                    }
                case .Failure(let error):
                    self.failureWithError(error)
                }
        }
//        print(request)
    }
    
    func POST() {
        if let data = uploadData {
            upload(data)
        }
        else {
            POST_normal()
        }
    }
    
    func POST_normal(){
        
        if let token = UserInfo.currentUser()?.token{
            let authHeader =  ["token": token]
            header = authHeader
        }else{
            header = nil
        }

        Alamofire.request(.POST,url!, parameters: parameters, headers:header)
            .validate()
            .responseJSON {response in
                switch response.result{
                    case .Success:
                        if let val = response.result.value {
                            print(val)
                            let json = JSON(val)
                            print("JSON: \(json)")
                            self.successWithResponse(json)
                        }
                    case .Failure(let error):
                        if let data = response.data, let utf8Text = String.init(data: data, encoding: NSUTF8StringEncoding) {
                            print("Data: \(utf8Text)")
                        }
                        self.failureWithError(error)
                }
        }
    }
    
    func PUT(){
        if let token = UserInfo.currentUser()?.token{
            let authHeader =  ["token": token]
            header = authHeader
        }else{
            header = nil
        }

        Alamofire.request(.PUT,url!, parameters: parameters, headers:header)
            .validate()
            .responseJSON {response in
                switch response.result{
                case .Success:
                    if let val = response.result.value {
                        // print("JSON: \(JSON)")
                        let json = JSON(val)
                        //                    print("JSON: \(json)")
                        self.successWithResponse(json)
                    }
                case .Failure(let error):
                    self.failureWithError(error)
                }
        }
    }
    
    
    func upload(data: [MultipartData]) {
        if let token = UserInfo.currentUser()?.token{
            let authHeader =  ["token": token]
            header = authHeader
        }else{
            header = nil
        }
        
        Alamofire.upload(.POST, url!,headers: header,
            multipartFormData: { multipartFormData in
            for data in self.uploadData! {
                multipartFormData.appendBodyPart(data: data.data, name: data.name, fileName: data.fileName, mimeType: data.mimeType)
            }
            for (key,value) in self.parameters {
                if let valueString = value as? String {
                    multipartFormData.appendBodyPart(data: valueString.dataUsingEncoding(NSUTF8StringEncoding)!, name: key)
                }
            }
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        upload.progress { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in
//                            print(totalBytesWritten)
                            
                            // This closure is NOT called on the main queue for performance
                            // reasons. To update your ui, dispatch to the main queue.
                            if self.currentServiceType == .FoodSpotReviewImageUploading {
                                dispatch_async(dispatch_get_main_queue()) {
//                                    print("Total bytes written on main queue: \(totalBytesWritten)")
                                    let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
                                    self.delegate?.imageUploadPrograss!(progress)
                                }
                            }
                        }
                        self.handleResponse(response)
                        self.delegate?.imageUploadPrograss?(1.0)

                        
                    }
                case .Failure( _):
                    print(encodingResult)
                }
        })
    }
    
    
    func DELETE(){
        if let token = UserInfo.currentUser()?.token{
            let authHeader =  ["token": token]
            header = authHeader
        }else{
            header = nil
        }

        _ = Alamofire.request(.DELETE,url!,headers:header)
            .validate()
            .responseJSON {response in
                switch response.result{
                case .Success:
                    if let val = response.result.value {
                        // print("JSON: \(JSON)")
                        let json = JSON(val)
                        //                    print("JSON: \(json)")
                        self.successWithResponse(json)
                    }
                case .Failure(let error):
//                    print(error)
//                    if let val = response.result.value {
//                        let json = JSON(val)
//                        //                            self.failureWithError(json)
//                    }else{
//                        //                            self.failureWithError(nil)
//                    }
                    self.failureWithError(error)
                }
        }
//        print(request)
    }
    
    
    func failureWithError(error: NSError?) {
        let restResponse = RestResponse()
        restResponse.error = error
        delegate?.didFailedToReceiveData!(restResponse)
    }
    
    func successWithResponse(response:JSON?){
        let restResponse = RestResponse()
        restResponse.response = response
        restResponse.requestData = self.requestInfo
        delegate?.didSuccessfullyReceiveData!(restResponse)
    }
    
    func handleResponse(response: Response<AnyObject, NSError>) {
        switch response.result {
        case .Success:
            if let val = response.result.value {
//                print("JSON: \(val)")
                let json = JSON(val)
                //                    print("JSON: \(json)")
                self.successWithResponse(json)
            }
        case .Failure(let error):
//            print(error)
            if let val = response.result.value {
//                let json = JSON(val)
//                print("error json: \(json)")
                //                            self.failureWithError(json)
            }
            else {
                //                            self.failureWithError(nil)
            }
            self.failureWithError(error)
        }
    }

    

}

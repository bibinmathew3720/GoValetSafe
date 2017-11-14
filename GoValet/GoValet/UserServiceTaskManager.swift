
//
//  UserServiceTaskManager.swift
//  GoValet
//
//  Created by Ajeesh T S on 28/12/16.
//  Copyright © 2016 Ajeesh T S. All rights reserved.
//

import UIKit

enum UserServiceType {
    case HotelList
    case SentValetRequest
    case CancelValetRequest
    case RequestDetails
}

extension UserServiceTaskManager : BaseServiceDelegates  {
    
    func didSuccessfullyReceiveData(response:RestResponse?){
        let responseData = response!.response!
        if let errorMsg = responseData["error"].string{
            managerDelegate?.didFinishTask(from: self, response: (data: nil, error: errorMsg))
            return
        }
        if currentServiceType == .SentValetRequest{
            let sucessRepose = ValetResonse.init(json: responseData)
            response?.responseModel = sucessRepose
            response?.requestCode = 1001
        }
        else if currentServiceType == .CancelValetRequest{
            if let msg = responseData["data"].string {
                response?.successMessage = msg
            }
        }
        else if currentServiceType == .RequestDetails{
            
            let sucessRepose = ValetResonse.init(json: responseData)
            response?.responseModel = sucessRepose
        }
        else{
            var hotelList = [Hotel]?()
            if let hotels = responseData["data"].array {
                hotelList = [Hotel]()
                for hotel in hotels {
                    let product = Hotel.init(dict: hotel)
                    hotelList?.append(product)
                }
                response?.responseModel = hotelList
            }
        }
        managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
    }
    
    func didFailedToReceiveData(response:RestResponse?){
        managerDelegate?.didFinishTask(from: self, response: (data: nil, error: nil))
    }
    
}


class UserServiceTaskManager: WebServiceTaskManager {
    
    var currentServiceType = UserServiceType.HotelList
    var isRepeatApi = false
    
    func getHotelsList(lattitude:String,longitude:String){
        let userService = UserOperationService()
        userService.delegate = self
        var params = [String: AnyObject]()
        params["user_latitude"] = lattitude
        params["user_longitude"] = longitude
        userService.parameters = params
        userService.getHotelsList()
    }
    
    func sendValetRequest(hotelId:String, valetCode:String?,scanImage: UIImage?){
        currentServiceType = .SentValetRequest
        let userService = UserOperationService()
        userService.delegate = self
        var params = [String: AnyObject]()
        params["hotel_id"] = hotelId
        if valetCode != nil{
            params["valet_code"] = valetCode!
        }
        userService.parameters = params
        if scanImage != nil{
            let data = UIImageJPEGRepresentation(scanImage!, 0.5)!
            let multipartData = MultipartData(data: data, name: "code_image", fileName: "image.jpg", mimeType: "image/jpeg")
            userService.uploadData = [multipartData]
        }
        userService.valetRequest()
    }
    
    func cancelRequest(requestID:String){
        currentServiceType = .CancelValetRequest
        let userService = UserOperationService()
        userService.delegate = self
        var params = [String: AnyObject]()
        params["id"] = requestID
        userService.parameters = params
        userService.cancelValetRequest()
    }
    
    func requestDetailsRequest(requestID:String){
        currentServiceType = .RequestDetails
        let userService = UserOperationService()
        userService.delegate = self
        var params = [String: AnyObject]()
        params["id"] = requestID
        userService.parameters = params
        userService.valetRequestDetails()
    }



}




//
//  ValetServiceManager.swift
//  GoValet
//
//  Created by Ajeesh T S on 24/01/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit
import SwiftyJSON


class ValetRequest: NSObject {
    var ID: String?
    var first_name: String?
    var country_code: String?
    var email: String?
    var userImage: String?
    var last_name: String?
    var dob: String?
    var userID: String?
    var mobile: String?
    
    var valet_image: String?
    var average_time: String?
    var created_dt: String?
    var real_time: String?
    var valet_code: String?
    
    init(json: JSON) {
        if let data = json["valet_code"].string {
            self.valet_code = data
        }
        if let data = json["id"].string {
            self.ID = data
        }
        if let data = json["valet_image"].string {
            self.valet_image = data
        }
        if let data = json["average_time"].string {
            self.average_time = data
        }
        if let data = json["created_dt"].string {
            self.created_dt = data
        }
        if let data = json["real_time"].string {
            self.real_time = data
        }
        if let dict = json["user"].dictionary {
            if let data = dict["mobile"]?.string {
                self.mobile = data
            }
            if let data = dict["id"]?.string {
                self.userID = data
            }
            if let data = dict["dob"]?.string {
                self.dob = data
            }
            if let data = dict["last_name"]?.string {
                self.last_name = data
            }
            if let data = dict["image"]?.string {
                self.userImage = data
            }
            if let data = dict["email"]?.string {
                self.email = data
            }
            if let data = dict["country_code"]?.string {
                self.country_code = data
            }
            if let data = dict["first_name"]?.string {
                self.first_name = data
            }
        }
        
    }

}



enum ValetServiceType {
    case UpdateStaffCount
    case FetchPendingRequest
    case UpdateStatus
    case NonMember
}

extension ValetServiceManager : BaseServiceDelegates {
    
    func didSuccessfullyReceiveData(response:RestResponse?){
        let responseData = response!.response!
        if let errorMsg = responseData["error"].string{
            managerDelegate?.didFinishTask(from: self, response: (data: nil, error: errorMsg))
            return
        }else{
            if currentServiceType == .UpdateStaffCount{
                if let successMsg = responseData["data"].string{
                    response?.successMessage = successMsg
                }
            }else{
                if let requests = responseData["data"].array{
                    var requestArray = [ValetRequest]()
                    for request in requests {
                        let obj = ValetRequest(json: request)
                        requestArray.append(obj)
                    }
                    response?.responseModel = requestArray

                }
                
                if let successMsg = responseData["data"].string{
                    response?.successMessage = successMsg
                }
            }
            managerDelegate?.didFinishTask(from: self, response: (data: response, error: nil))
        }
    }
    
    func didFailedToReceiveData(response:RestResponse?){
        managerDelegate?.didFinishTask(from: self, response: (data: nil, error: nil))
    }
}

class ValetServiceManager: WebServiceTaskManager {
    var currentServiceType = ValetServiceType.UpdateStaffCount
    func updateStaffCount(staffCount:String, parkingcount : String?){
        let valetservice = ValetManagerWebService()
        valetservice.delegate = self
        var params = [String: AnyObject]()
        params["staff_count"] = staffCount
        if parkingcount != nil{
            let pCount : String  = parkingcount!
            params["parking_count"] = pCount
        }
        valetservice.parameters = params
        valetservice.updateStaffCount()
    }
    
    func fetchAllPendinRequest(){
        currentServiceType =  .FetchPendingRequest
        let valetservice = ValetManagerWebService()
        valetservice.delegate = self
        valetservice.getAllPendingRequest()
    }
    
    func changeValetStatus(isReady: Bool, iD : String){
        currentServiceType =  .FetchPendingRequest
        let valetservice = ValetManagerWebService()
        valetservice.delegate = self
        var params = [String: AnyObject]()
        if isReady == true{
            params["status"] = "ready"
        }else{
            params["status"] = "cancel"
        }
        params["id"] = iD

        valetservice.parameters = params

        valetservice.updateValetRequestStatus()
    }
    
    func nonMemberRequest(){
        currentServiceType =  .NonMember
        let valetservice = ValetManagerWebService()
        valetservice.delegate = self
        valetservice.nonMemberRequestService()
    }
    
}


//
//  CommonWebService.swift
//  
//
//  Created by Ajeesh T S on 19/01/17.
//
//

import UIKit

class CommonWebService: BaseWebService {

    func getHistoryList(){
        var params = [String: AnyObject]()
        let currentLanguage = NSLocale.preferredLanguages()[0]
        if currentLanguage == "ar-US"{
            params["lang"] = "arabic"
        }
        else{
            params["lang"] = "eng"
        }
        self.parameters = params
        self.url = "\(baseUrl)request/history"
        POST()
    }
    
    func viewUSerProfile(){
        self.url = "\(baseUrl)user/view_profile"
        POST()
    }
    
    func addCar(){
        self.url = "\(baseUrl)user/add_car"
        POST()
    }
    
    func updateProfile(){
        self.url = "\(baseUrl)user/edit_profile"
        POST()
    }
    
    
    
    
    

}

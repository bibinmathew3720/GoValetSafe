//
//  UserInfo.swift
//  CSC Staff
//
//  Created by Johnykutty Mathew on 27/06/16.
//  Copyright © 2016 CSC. All rights reserved.
//

import UIKit
import SwiftyJSON

class Car :NSObject,NSCoding{
    var carImage: String?
    var name: String?
    var carId: String?
    init(json: JSON) {
        if let data = json["id"].string {
            self.carId = data
        }
        if let data = json["title"].string {
            self.name = data
        }
        if let data = json["image"].string {
            self.carImage = data
        }
    }
    
    
    func encodeWithCoder(aCoder: NSCoder) {
        if let value = carImage {
            aCoder.encodeObject(value, forKey: "carImage")
        }
        if let value = name {
            aCoder.encodeObject(value, forKey: "name")
        }
        if let value = carId {
            aCoder.encodeObject(value, forKey: "carId")
        }
    }
    
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        carImage = aDecoder.decodeObjectForKey("carImage") as? String
        name = aDecoder.decodeObjectForKey("name") as? String
        carId = aDecoder.decodeObjectForKey("carId") as? String
    }
}

class UserInfo: NSObject, NSCoding {
    
    var status: String?
    var messge: String?
    var token: String?
    var userName: String?
    var subScriptionStatus: String?
    var userFirstName: String?
    var userLastName: String?
    var dob: String?
    var countrycode: String?
    var email: String?
    var password: String?
    var currentRequestID : String?

    var phone: String?

    var profileImage: String?
    var userId: String?
    var address1: String?
    var address2: String?
    var street: String?
    var city: String?

    var cars : [Car]?
    var hotels : [Hotel]?
    
    var userType : String = "Customer"
    
    private static var __currentUser: UserInfo? = nil
    class func createSessionWith(json: JSON) {
        __currentUser = UserInfo(json: json)
    }
    
    class func currentUser() -> UserInfo? {
        return __currentUser
    }
    
    init(json: JSON) {
        if let data = json["message"].string {
            self.messge = data
        }
         
        if let dict = json["data"].dictionary {
            
            
            if let data = dict["user_type"]?.string {
                self.userType = data
            }
            if let data = dict["token"]?.string {
                self.token = data
            }
            if let data = dict["first_name"]?.string {
                self.userFirstName = data
                self.userName = data
            }
            if let data = dict["last_name"]?.string {
                self.userLastName = data
                let fname : String = self.userName!
                self.userName =  "\(fname) \(data)"
            }
            if let data = dict["email"]?.string {
                self.email = data
            }
            if let data = dict["subscription_status"]?.string {
                self.subScriptionStatus = data
            }
            if let data = dict["mobile"]?.string {
                self.phone = data
            }
            if let data = dict["country_code"]?.string {
                self.countrycode = data
            }
            if let data = dict["dob"]?.string {
                self.dob = data
            }
            if let data = dict["image"]?.string {
                self.profileImage = data
            }
            if let carArray = dict["car"]?.array {
                cars = [Car]()
                for car in carArray {
                    let carObj = Car.init(json: car)
                    cars?.append(carObj)
                }
            }
            if let carArray = dict["hotel"]?.array {
                hotels = [Hotel]()
                for car in carArray {
                    let carObj = Hotel.init(dict: car)
                    hotels?.append(carObj)
                }
            }

            
            
        }
        
        
    }
//    
    func save() {
        let encodedData = NSKeyedArchiver.archivedDataWithRootObject(self)
        saveData(encodedData)
    }
    
    func clearSession() {
        saveData(nil)
    }
    
    class func restoreSession() -> Bool {
        if let data = NSUserDefaults.standardUserDefaults().objectForKey("userSession") as? NSData {
            __currentUser = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? UserInfo
        }
        return (__currentUser != nil)
    }
    
    private func saveData(data: NSData?) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.removeObjectForKey("userSession")
        userDefaults.setObject(data, forKey: "userSession")
        userDefaults.removeObjectForKey("lattiutde")
        userDefaults.removeObjectForKey("longitude")
        userDefaults.synchronize()
    }

    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(cars, forKey: "cars")
        if let value = cars {
            aCoder.encodeObject(value, forKey: "cars")
        }
        
        aCoder.encodeObject(userType, forKey: "userType")
        if let value = status {
            aCoder.encodeObject(value, forKey: "status")
        }
        
        if let value = token {
            aCoder.encodeObject(value, forKey: "token")
        }
        
        if let value = password {
            aCoder.encodeObject(value, forKey: "password")
        }
        if let value = currentRequestID {
            aCoder.encodeObject(value, forKey: "currentRequestID")
        }
        
        
        if let value = messge {
            aCoder.encodeObject(value, forKey: "messge")
        }
        if let value = userName {
            aCoder.encodeObject(value, forKey: "userName")
        }
        if let value = userId {
            aCoder.encodeObject(value, forKey: "userId")
        }
        if let value = email {
            aCoder.encodeObject(value, forKey: "email")
        }
        if let value = phone {
            aCoder.encodeObject(value, forKey: "phone")
        }
        if let value = profileImage {
            aCoder.encodeObject(value, forKey: "profileImage")
        }
        if let value = address1 {
            aCoder.encodeObject(value, forKey: "address1")
        }
        if let value = address2 {
            aCoder.encodeObject(value, forKey: "address2")
        }
        if let value = street {
            aCoder.encodeObject(value, forKey: "street")
        }
        if let value = city {
            aCoder.encodeObject(value, forKey: "city")
        }
        if let value = userFirstName {
            aCoder.encodeObject(value, forKey: "userFirstName")
        }
        if let value = userLastName {
            aCoder.encodeObject(value, forKey: "userLastName")
        }
        if let value = countrycode {
            aCoder.encodeObject(value, forKey: "countrycode")
        }
        if let value = dob {
            aCoder.encodeObject(value, forKey: "dob")
        }
        
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        cars = (aDecoder.decodeObjectForKey("cars") as? [Car])!
        userType = (aDecoder.decodeObjectForKey("userType") as? String)!
        userId = aDecoder.decodeObjectForKey("userId") as? String
        status = aDecoder.decodeObjectForKey("status") as? String
        password = aDecoder.decodeObjectForKey("password") as? String
        currentRequestID = aDecoder.decodeObjectForKey("currentRequestID") as? String
        token = aDecoder.decodeObjectForKey("token") as? String
        messge = aDecoder.decodeObjectForKey("messge") as? String
        userName = aDecoder.decodeObjectForKey("userName") as? String
        email = aDecoder.decodeObjectForKey("email") as? String
        phone = aDecoder.decodeObjectForKey("phone") as? String
        profileImage = aDecoder.decodeObjectForKey("profileImage") as? String
        address1 = aDecoder.decodeObjectForKey("address1") as? String
        address2 = aDecoder.decodeObjectForKey("address2") as? String
        street = aDecoder.decodeObjectForKey("street") as? String
        city = aDecoder.decodeObjectForKey("city") as? String
        userFirstName = aDecoder.decodeObjectForKey("userFirstName") as? String
        userLastName = aDecoder.decodeObjectForKey("userLastName") as? String
        countrycode = aDecoder.decodeObjectForKey("countrycode") as? String
        dob = aDecoder.decodeObjectForKey("dob") as? String
    }

}

//
//  HomeViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 17/12/16.
//  Copyright © 2016 Ajeesh T S. All rights reserved.
//

import UIKit
import CameraManager
import CameraEngine
import MessageUI

let KValetRequestTimerTime : NSTimeInterval = 20
let KHotelListTimerTime : NSTimeInterval = 10

extension HomeViewController: WebServiceTaskManagerProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        self.removeLoadingIndicator()
        
        if response.error != nil{
            let errmsg : String = response.error! as String
            self.showAlert("Warning!".localized, message: errmsg)
            return
        }
        if response.data == nil{
//            if response.error != nil{
//            let errmsg : String = response.error! as String
////            self.successView.hidden = false
//                self.showAlert("Warning!".localized, message: errmsg)
//            }
        }else{
            if let managerType = manager as? UserServiceTaskManager{
                if managerType.currentServiceType == UserServiceType.SentValetRequest{
                    self.successView.hidden = false
                    self.requestType = 1
                    self.configureSuccesView(1)
                    valetSucessResult = response.data?.responseModel as? ValetResonse
                    if let waitingTime = valetSucessResult?.averageTime{
                        let strVal : String = waitingTime
                        self.count = Float(strVal)!
                        if valetSucessResult?.iD != nil{
                            let rId : String = (valetSucessResult?.iD)!
                            UserInfo.currentUser()?.currentRequestID = rId
                            UserInfo.currentUser()?.save()
                        }
                        self.requestType = 1
                        showTimerValue()
//                        self.configureSuccesView(1)
                    }
                }
                else if managerType.currentServiceType == .CancelValetRequest{
                    self.updateTimer.invalidate()
                    if let msg = response.data?.successMessage {
                        self.showAlert("GoValet", message: msg)
                    }
                }
                else if managerType.currentServiceType == UserServiceType.RequestDetails{
                    valetSucessResult = response.data?.responseModel as? ValetResonse
                    if let status = valetSucessResult?.status{
                        let statusVal : String = status
                        if valetSucessResult?.iD != nil{
                            let rId : String = (valetSucessResult?.iD)!
                            UserInfo.currentUser()?.currentRequestID = rId
                            UserInfo.currentUser()?.save()
                        }
                        if statusVal == "cancelled"{
//                            cancelled , completed, pending
                            self.successView.hidden = false
                            self.requestType = 2
                            self.configureSuccesView(2)
                        }
                        else if statusVal == "pending"{
                            self.successView.hidden = false
                            self.requestType = 1
                            if managerType.isRepeatApi == false{
                                self.configureSuccesView(1)
                            }
                            print(valetSucessResult?.averageTime)
                            if let waitingTime = valetSucessResult?.averageTime{
                                let strVal : String = waitingTime
                                
                                if managerType.isRepeatApi == false{
                                    self.count = Float(strVal)!
                                }
                                if self.count > 0{
                                    if managerType.isRepeatApi == false{
                                        self.showTimerValue()
                                    }
                                }
                            }
                            else{
                                self.updateTimer.invalidate()
                               self.count = (valetSucessResult?.avgTimeFloat)!
                                self.showTimerValue()
                            }
                        }
                        else if statusVal == "completed"{
                            self.successView.hidden = false
                            self.requestType = 3
                            self.configureSuccesView(3)
                        }
                    }
                }
                else{
                    if let hotelsArray = response.data?.responseModel as? [Hotel] {
                        self.hotelList = hotelsArray
                        print(hotelsArray)
                      //  hotelListTable.hidden = false
                        if (selectedHotel == nil){
                            selectedHotel = hotelList.first
                        }
                        else{
                            let filteredArray = hotelList.filter( { (hotel: Hotel) -> Bool in
                                return hotel.hotelId == self.selectedHotel?.hotelId
                            })
                            selectedHotel = filteredArray.first
                        }
                        self.showSelectedHotelData()
                        self.hotelListTable.reloadData()
                    }
                }
            }
           
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        picker.dismissViewControllerAnimated(true, completion: nil)
        let tempImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.scanImageView.image = tempImage
        isSelectedImage = true
    }
}

class HomeViewController: BaseViewController ,MFMessageComposeViewControllerDelegate{

    var manager: OneShotLocationManager?
    var selectedHotel :  Hotel?
    var valetSucessResult :  ValetResonse?

    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var hotelListTable : UITableView!
    @IBOutlet weak var selectedHotelImageView : UIImageView!
    @IBOutlet weak var distacneLbl : UILabel!
    @IBOutlet weak var hotelNameLbl : UILabel!
    @IBOutlet weak var selectedHotelContainer : UIView!

    @IBOutlet weak var typeCodeTxtFld : CustomTextField!
    @IBOutlet weak var scanCodeImageContainer : UIView!
    @IBOutlet weak var scanCodeBtn : UIButton!
    @IBOutlet weak var scanImageView : UIImageView!
    @IBOutlet weak var imagePreviewcloseBtn : UIButton!


    var requestType = 1
    @IBOutlet weak var successView : UIView!
    @IBOutlet weak var successViewcloseBtn : UIButton!

    @IBOutlet weak var successViewContainer : UIView!
    @IBOutlet weak var avgTimeLbl : UILabel!
    @IBOutlet weak var hotelAvgTimeLbl : UILabel!

    var imagePicker: UIImagePickerController!

    var isSelectedImage = false
    var count : Float = 0.0

    var hotelList = [Hotel]()
    
    
    let cameraManager = CameraManager()
    let cameraEngine = CameraEngine()

    
    var isCameraShowingMode = true
    
    var recursiveApiCallingTImer = NSTimer()
    var updateTimer = NSTimer()
    var hotelListTimer = NSTimer()
    // MARK: - @IBOutlets
    
    @IBOutlet weak var cameraView: UIView!

    
    override func viewDidLoad() {
        self.showAppThemeNavigationBar = true
        imagePreviewcloseBtn.hidden = true
        super.viewDidLoad()
        self.enablePushnotification()
        self.getValetRequestDetails()
        self.timerForUpdatingHotelList()
        self.timerForGetRequestApiDetails()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("sideMenuOpen:"), name: "SideMenuOpenNotification", object: nil)
        hotelListTable.tableFooterView = UIView()
        hotelListTable.separatorColor = UIColor(red:0.24, green:0.24, blue:0.25, alpha:1)
        hotelListTable.hidden = true
        selectedHotelContainer.roundCornerValue(3.0)
        scanCodeBtn.roundCornerValue(3.0)
        avgTimeLbl.roundCornerValue(3.0)
        scanCodeImageContainer.roundCornerValue(3.0)
        successViewContainer.roundCornerValue(3.0)
        hotelAvgTimeLbl.roundCornerValue(3.0)
        typeCodeTxtFld.roundCorner()
        let logo = UIImage(named: "logNav")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        getHotelListFromServer()
        self.cameraEngine.sessionPresset = .Photo
        self.cameraEngine.startSession()
        self.getHotelBasedUserCurrentLocation()
        self.orLabel.text = "OR".localized
    }
    
    func timerForUpdatingHotelList(){
        hotelListTimer = NSTimer.scheduledTimerWithTimeInterval(KHotelListTimerTime, target: self, selector: Selector("getHotelBasedUserCurrentLocation"), userInfo: nil, repeats: true)
    }
    
    
    func enablePushnotification(){
        // Override point for customization after application launch.
        let application = UIApplication.sharedApplication()
        let notificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
        let pushNotificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
        application.registerUserNotificationSettings(pushNotificationSettings)
        application.registerForRemoteNotifications()
        
        registerForPushNotifications(application)
    }
    
    func registerForPushNotifications(application: UIApplication) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
    }
    
    func showPasswordConfirmAlert(){
        let alertController = UIAlertController(title: "", message: "Please enter your Password", preferredStyle: .Alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .Default) { (_) in
            if let field = alertController.textFields![0] as? UITextField {
                // store your data
                NSUserDefaults.standardUserDefaults().setObject(field.text, forKey: "userEmail")
                NSUserDefaults.standardUserDefaults().synchronize()
            } else {
                // user did not fill field
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel) { (_) in }
        
        alertController.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Email"
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    func configureSuccesView(type: Int){
        if type == 1{
            successViewcloseBtn.setTitle("Cancel".localized, forState: .Normal)
            if self.valetSucessResult?.averageTime != nil{
                let strVal : String = (self.valetSucessResult?.averageTime)!
                 //let val = Float(strVal)!
                avgTimeLbl.text = "Average Time - \(strVal) Mins"
                let currentLanguage = NSLocale.preferredLanguages()[0]
                if currentLanguage == "ar-US"{
                    avgTimeLbl.text = "الـوقـت المتوقــع: \(strVal) دقيقة"
                }
            }else{
                avgTimeLbl.text = "Average Time - "
                let currentLanguage = NSLocale.preferredLanguages()[0]
                if currentLanguage == "ar-US"{
                    avgTimeLbl.text = "الـوقـت المتوقــع: دقائق"
                }
            }

        }
        else if type == 2{
            self.updateTimer.invalidate()
            successViewcloseBtn.setTitle("Ok", forState: .Normal)
            avgTimeLbl.text = "Request has been cancelled"
        }
        else if type == 3{
            self.updateTimer.invalidate()
            successViewcloseBtn.setTitle("Ok", forState: .Normal)
            avgTimeLbl.text = "Your car is ready"
        }

    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        cameraManager.resumeCaptureSession()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
//        cameraManager.stopCaptureSession()
    }
    
    override func viewDidLayoutSubviews() {
        let layer = self.cameraEngine.previewLayer
        layer.frame = self.scanCodeImageContainer.bounds
        self.scanCodeImageContainer.layer.insertSublayer(layer, atIndex: 0)
        self.scanCodeImageContainer.layer.masksToBounds = true
    }
    
    func addCameraToView()
    {
        cameraManager.addPreviewLayerToView(scanCodeImageContainer, newCameraOutputMode: CameraOutputMode.StillImage)
        cameraManager.showErrorBlock = { [weak self] (erTitle: String, erMessage: String) -> Void in
            let alertController = UIAlertController(title: erTitle, message: erMessage, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in  }))
            self?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func locationBtnClicked(){
        if hotelList.count > 0{
            hotelListTable.hidden = false
        }else{
            getHotelListFromServer()
        }
    }
    
    @IBAction func currentLocationBtnClicked(){
        self.getHotelBasedUserCurrentLocation()
    }
    
    
    func getHotelListFromServer(){
        self.getHotelBasedUserCurrentLocation()

//        if let lattiutde = NSUserDefaults.standardUserDefaults().objectForKey("lattiutde") as? String {
//            if let longitude = NSUserDefaults.standardUserDefaults().objectForKey("longitude") as? String {
//                self.getHotelListFromService(lattiutde, longitude: longitude)
//            }
//        }else{
//           self.getHotelBasedUserCurrentLocation()
//        }
    }
    
    func getHotelBasedUserCurrentLocation(){
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            // fetch location or an error
            if let loc = location {
                print(location)
                let user_lat = String(format: "%f", loc.coordinate.latitude)
                let user_long = String(format: "%f", loc.coordinate.longitude)
                NSUserDefaults.standardUserDefaults().setObject(user_lat, forKey: "lattiutde")
                NSUserDefaults.standardUserDefaults().setObject(user_long, forKey: "longitude")
                self.getHotelListFromService(user_lat, longitude: user_long)
            } else if let err = error {
                //                self.showLocationPickerMapWithDefaultLocation()
                print(err.localizedDescription)
                if let lattiutde = NSUserDefaults.standardUserDefaults().objectForKey("lattiutde") as? String {
                    if let longitude = NSUserDefaults.standardUserDefaults().objectForKey("longitude") as? String {
                        self.getHotelListFromService(lattiutde, longitude: longitude)
                    }
                }
            }
            self.manager = nil
        }
    }
    
    @IBAction func contactBtnClicked(){
        let alerController = UIAlertController(title: "", message: "contact", preferredStyle: .ActionSheet)
        alerController.addAction(UIAlertAction(title: "Call", style: .Default, handler: {(action:UIAlertAction) in
            self.calltoNumber()
        }));
        alerController.addAction(UIAlertAction(title: "SMS", style: .Default, handler: {(action:UIAlertAction) in
            self.openSMSview()
        }));
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .Cancel, handler: nil)
        alerController.addAction(cancelAction)
        presentViewController(alerController, animated: true, completion: nil)
    }
    
    func openSMSview(){
        let messageVC = MFMessageComposeViewController.init()
        messageVC.body = " ";
        if valetSucessResult?.hotel?.phone != nil{
            let phone  : String = (valetSucessResult?.hotel?.phone)!
            messageVC.recipients = [phone]
        }
        messageVC.messageComposeDelegate = self;
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    func calltoNumber(){
        if valetSucessResult?.hotel?.phone != nil{
            let phone  : String = (valetSucessResult?.hotel?.phone)!
            if let url = NSURL(string: "tel://\(phone)") where UIApplication.sharedApplication().canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        //... handle sms screen actions
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelBtnClicked(){
        self.successView.hidden = true
        scanImageView.image = nil
        typeCodeTxtFld.text = ""
        if self.requestType == 1{
            if valetSucessResult?.iD != nil{
                UserInfo.currentUser()?.currentRequestID = nil
                UserInfo.currentUser()?.save()
                self.cancelValetRequest((valetSucessResult?.iD)!)
            }
        }
        else if self.requestType == 3{
            UserInfo.currentUser()?.currentRequestID = nil
            UserInfo.currentUser()?.save()
        }
        self.resetImageCapturing()
        
    }
    
    @IBAction func imageCloseBtnClicked(){
        self.resetImageCapturing()
    }
    
    
    func resetImageCapturing(){
        self.scanCodeBtn.userInteractionEnabled = true
        imagePreviewcloseBtn.hidden = true
        self.scanCodeImageContainer.sendSubviewToBack(self.scanImageView)
        self.scanImageView.hidden = true
        self.scanImageView.image = nil
        self.isSelectedImage = false
        self.isCameraShowingMode = true
    }
    
    @IBAction func scanImageBtnClicked(){
        
        self.cameraEngine.capturePhoto { (image: UIImage?, error: NSError?) -> (Void) in
            self.scanImageView.hidden = false
            self.scanCodeImageContainer.bringSubviewToFront(self.scanImageView)
            self.scanCodeImageContainer.bringSubviewToFront(self.imagePreviewcloseBtn)
            self.scanImageView.image = image
            self.isSelectedImage = true
            self.isCameraShowingMode = false
            self.imagePreviewcloseBtn.hidden = false
            self.scanCodeBtn.userInteractionEnabled = false
        }
      
    }

    @IBAction func getItBtnClicked(){
        if isSelectedImage == false{
            if self.typeCodeTxtFld.text?.isBlank == true{
                self.showWarningAlert("Please Add Code")
                return
            }
        }
        if self.typeCodeTxtFld.text?.isBlank == true{
            if isSelectedImage == false{
                self.showWarningAlert("Please Add Code")
                return
            }
        }
        if self.selectedHotel == nil{
            self.showWarningAlert("Please Select the Hotel")
            return
        }
        self.addLoaingIndicator()
        let hotelListManager = UserServiceTaskManager()
        hotelListManager.managerDelegate = self
//        self.requestType = 1
        if self.typeCodeTxtFld.text?.isBlank == true{
            if scanImageView.image != nil{
                hotelListManager.sendValetRequest((selectedHotel?.hotelId!)!, valetCode:nil, scanImage: scanImageView.image!)
            }else{
                hotelListManager.sendValetRequest((selectedHotel?.hotelId!)!, valetCode:typeCodeTxtFld.text, scanImage: nil)
            }
        }else{
            hotelListManager.sendValetRequest((selectedHotel?.hotelId!)!, valetCode:typeCodeTxtFld.text, scanImage: nil)
        }
        
    }

    
    func getHotelListFromService(lattitude:String,longitude:String){
        let hotelListManager = UserServiceTaskManager()
        hotelListManager.managerDelegate = self
        hotelListManager.getHotelsList(lattitude, longitude: longitude)
    }
    
    func cancelValetRequest(requestID: String){
        self.addLoaingIndicator()
        let hotelListManager = UserServiceTaskManager()
        hotelListManager.managerDelegate = self
        hotelListManager.cancelRequest(requestID)
    }
    
    func getValetRequestDetails(){
        if UserInfo.currentUser()?.currentRequestID != nil{
            let requestID : String = (UserInfo.currentUser()?.currentRequestID)!
//            self.addLoaingIndicator()
            let hotelListManager = UserServiceTaskManager()
            hotelListManager.managerDelegate = self
            hotelListManager.requestDetailsRequest(requestID)
        }
    }
    

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 45
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hotelList.count > 0{
            return hotelList.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell : HotelListCell = tableView.dequeueReusableCellWithIdentifier("hotelListCell", forIndexPath: indexPath) as! HotelListCell
        cell.showData(hotelList[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        selectedHotel = hotelList[indexPath.row]
        print(selectedHotel?.name)
         print(selectedHotel?.hotelId)
        print(selectedHotel?.avgTime)
        tableView.hidden = true
        self.showSelectedHotelData()
    }
    
    func showSelectedHotelData(){
        if let name = self.selectedHotel?.name{
            hotelNameLbl.text = name
        }
        if let distc = selectedHotel?.distance{
            distacneLbl.text = "Distance : \(distc)"
        }
        if let imageUrl = selectedHotel?.image{
            selectedHotelImageView.sd_setImageWithURL(NSURL(string:(imageUrl)))
        }
        if let avgTime = selectedHotel?.avgTime{
            hotelAvgTimeLbl.text = "Average Time - \(avgTime) Mins"
            let currentLanguage = NSLocale.preferredLanguages()[0]
            if currentLanguage == "ar-US"{
                hotelAvgTimeLbl.text = "الـوقـت المتوقــع: \(avgTime) دقيقة"
            }
        }
        

    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = CGPointZero
        }
    }
    
    
    
    
    func sideMenuOpen(notification: NSNotification){
        //        addPush = true
        let dict = notification.object as! NSDictionary
        let receivednumber : String = dict["menu"] as! String
        let order :Int =  Int(receivednumber)!
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        switch order {
        case 1:
            let profiletVC = self.storyboard?.instantiateViewControllerWithIdentifier("ProfileVC") as! ProfileViewController
            self.navigationController?.pushViewController(profiletVC, animated: false)
        case 2:
            let paymentVC = self.storyboard?.instantiateViewControllerWithIdentifier("PaymentVC") as! PaymentViewController
            self.navigationController?.pushViewController(paymentVC, animated: true)
        case 3:
            let historyVC = self.storyboard?.instantiateViewControllerWithIdentifier("HostoryVC") as! HistoryViewController
            self.navigationController?.pushViewController(historyVC, animated: true)
        case 4://For Manage Cards(User)
            let paymentVC = self.storyboard?.instantiateViewControllerWithIdentifier("paymentVC") as! PaymentVC
            self.navigationController?.pushViewController(paymentVC, animated: true)
        case 5://For List Cards(User)
            let paymentVC = self.storyboard?.instantiateViewControllerWithIdentifier("addCardVC") as! AddCardVC
            self.navigationController?.pushViewController(paymentVC, animated: true)
        default:
            break
        }
        
        
        //        self.presentViewController(viewController, animated: true, completion: nil)
        
        //        let receivedString = dict["mytext"]
    }

    
    func showTimerValue(){
        if self.valetSucessResult?.averageTime != nil{
            let strVal : String = (self.valetSucessResult?.averageTime)!
            count = Float(strVal)!
            //count = count - 1
                avgTimeLbl.text = "Average Time - \(count) Mins"
                let currentLanguage = NSLocale.preferredLanguages()[0]
                if currentLanguage == "ar-US"{
                    avgTimeLbl.text = "الـوقـت المتوقــع: \(count) دقيقة"
                    
                }
             count=count*60
            updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("update"), userInfo: nil, repeats: true)
        }
        else{
            if(self.valetSucessResult?.isInSeconds == "YES"){
                let Minute:Int16 = Int16(count/60)
                let Seconds:Int16 = Int16(count%60)
                avgTimeLbl.text = "Average Time - \(Minute):\(Seconds) Mins"
                let currentLanguage = NSLocale.preferredLanguages()[0]
                if currentLanguage == "ar-US"{
                    avgTimeLbl.text = "الـوقـت المتوقــع: \(Minute):\(Seconds) دقيقة"
                }
                updateTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector:Selector("update"), userInfo: nil, repeats: true)
            }
        }
    }
    
    func update() {
        if(count > 0) {
            count = count - 1
            if count > 0{
                let Minute:Int16 = Int16(count/60)
                let Seconds:Int16 = Int16(count%60)
                avgTimeLbl.text = "Average Time - \(Minute):\(Seconds) Mins"
                let currentLanguage = NSLocale.preferredLanguages()[0]
                if currentLanguage == "ar-US"{
                    avgTimeLbl.text = "الـوقـت المتوقــع: \(Minute):\(Seconds) دقيقة"
                }
            }else{
                self.requestType = 3
                self.configureSuccesView(3)
            }
        }
        else{
            print("Time Out")
        }
    }
    
    
    
    func timerForGetRequestApiDetails(){
        recursiveApiCallingTImer = NSTimer.scheduledTimerWithTimeInterval(KValetRequestTimerTime, target: self, selector: Selector("callGetRequestApiDetailsAPI"), userInfo: nil, repeats: true)
    }
    
    func callGetRequestApiDetailsAPI(){
        if UserInfo.currentUser()?.currentRequestID != nil{
            let requestID : String = (UserInfo.currentUser()?.currentRequestID)!
            //            self.addLoaingIndicator()
            let hotelListManager = UserServiceTaskManager()
            hotelListManager.managerDelegate = self
            hotelListManager.isRepeatApi = true
            hotelListManager.requestDetailsRequest(requestID)

        }
    }
    
    
}

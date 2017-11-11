

//
//  ManagerHomeViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 24/01/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

//ValetMngrVC
let KValetMaangerRequestTimerTime : NSTimeInterval = 20

var parkingCount = ""

extension ManagerHomeViewController: WebServiceTaskManagerProtocol, RequestCellDelegate {
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        self.removeLoadingIndicator()
        if response.error != nil{
            let errmsg : String = response.error! as String
            if errmsg.isBlank == false{
                self.showAlert("Warning!".localized, message: errmsg)
            }
        }else{
            let servicemanger : ValetServiceManager = manager as! ValetServiceManager
            if servicemanger.currentServiceType == .UpdateStaffCount{
                parkingCount = self.staffTextNumTxtFld.text!
                self.parkingNumLbl.text = self.staffTextNumTxtFld.text
                self.popupConterView.hidden = true
                if response.data?.successMessage != nil{
                    if response.data?.successMessage?.isBlank == false{
                        self.showUpdateCountMsgAlert(response.data?.successMessage)
                    }
                }
                self.showUpdateCountMsgAlert(response.data?.successMessage)
            }else if servicemanger.currentServiceType == .NonMember{
                self.fetchAllPendingRequest()
            }
            else if servicemanger.currentServiceType == .FetchPendingRequest{
                if let requestArray = response.data?.responseModel as? [ValetRequest] {
                    self.valetRequestList = requestArray
                    self.listTableView.reloadData()
                }

            }else{
                if response.data?.successMessage != nil{
                    if response.data?.successMessage?.isBlank == false{
                        self.showAlert(nil, message: response.data?.successMessage)
                    }
                }
            }

        }
    }
    
    func cancelButtonClicked(cell:RequestTableViewCell){
        if let iD = cell.request?.ID {
            let idStr : String = iD
            self.cancelRequest(idStr)
            self.valetRequestList.removeAtIndex(cell.row)
            self.listTableView.reloadData()
        }
    
    }
    
    func callButtonClicked(cell:RequestTableViewCell){
        self.showCallButtonConfirmation("")
    }
    
    func readyButtonClicked(cell:RequestTableViewCell){
        if let iD = cell.request?.ID {
            let idStr : String = iD
            self.readyRequest(idStr)
        }
        self.valetRequestList.removeAtIndex(cell.row)
        self.listTableView.reloadData()
    }
    
    func imageButtonClicked(cell:RequestTableViewCell){
        imageDetailedConterView.hidden = false
        if let imageUrl = cell.request?.valet_image{
            detailedImageView.sd_setImageWithURL(NSURL(string:(imageUrl)))
        }

    }

    func showCallButtonConfirmation(number:String){
        let optionMenu = UIAlertController(title: number, message:"Do you want to call", preferredStyle: .ActionSheet)
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.callNumber(number)
        })
        let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(yesAction)
        optionMenu.addAction(cancelAction)
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func callNumber(phoneNumber:String) {
        if let phoneCallURL:NSURL = NSURL(string:"tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.sharedApplication()
            if (application.canOpenURL(phoneCallURL)) {
                application.openURL(phoneCallURL);
            }
        }
    }

}

class ManagerHomeViewController: BaseViewController,UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var popupConterView : UIView!
    @IBOutlet weak var countLblView : UIView!

    @IBOutlet weak var homeMainViewContiner : UIView!
    @IBOutlet weak var staffTextNumTxtFld : CustomTextField!
    @IBOutlet weak var parkingNumTxtFld : CustomTextField!
    @IBOutlet weak var parkingNumLbl : UILabel!
    @IBOutlet weak var submitBtn : UIButton!
    @IBOutlet weak var listTableView : UITableView!
    @IBOutlet weak var imageDetailedConterView : UIView!
    @IBOutlet weak var detailedImageView : UIImageView!


    
    var valetRequestList = [ValetRequest]()


    override func viewDidLoad() {
        self.showAppThemeNavigationBar = true
        super.viewDidLoad()
        self.addLogo()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("sideMenuOpen:"), name: "SideMenuOpenNotification", object: nil)
        popupConterView.layer.cornerRadius = 5.0
        homeMainViewContiner.hidden = false
        popupConterView.hidden = false
        listTableView.tableFooterView = UIView()
        staffTextNumTxtFld.roundCornerValue(3.0)
        parkingNumTxtFld.roundCornerValue(3.0)
        countLblView.roundCornerValue(3.0)
        listTableView.roundCornerValue(3.0)
        listTableView.backgroundColor = UIColor.clearColor()
        imageDetailedConterView.hidden = true

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.parkingNumLbl.text = parkingCount
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
            let paymentVC = self.storyboard?.instantiateViewControllerWithIdentifier("StaffCountVC") as! StaffCountUIViewController
            self.navigationController?.pushViewController(paymentVC, animated: true)
        case 3:
            let historyVC = self.storyboard?.instantiateViewControllerWithIdentifier("HostoryVC") as! HistoryViewController
            self.navigationController?.pushViewController(historyVC, animated: true)
        case 4://For Manage Cards User
            let paymentVC = self.storyboard?.instantiateViewControllerWithIdentifier("paymentVC") as! PaymentVC
            self.navigationController?.pushViewController(paymentVC, animated: true)
        default:
            break
        }
        
        
        //        self.presentViewController(viewController, animated: true, completion: nil)
        
        //        let receivedString = dict["mytext"]
    }

    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 80
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if valetRequestList.count > 0{
            return valetRequestList.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("RequestCell", forIndexPath: indexPath) as! RequestTableViewCell
        cell.delegate = self
        cell.row = indexPath.row
        cell.request = valetRequestList[indexPath.row]
        cell.showData()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }

    
    @IBAction func submitButtonClicked(){
        if self.staffTextNumTxtFld.text?.isBlank == false{
            self.addLoaingIndicator()
            let serviceManager = ValetServiceManager()
            serviceManager.managerDelegate = self
            if self.parkingNumTxtFld.text?.isBlank == false{
                serviceManager.updateStaffCount(self.staffTextNumTxtFld.text!, parkingcount: self.parkingNumTxtFld.text!)
            }else{
                serviceManager.updateStaffCount(self.staffTextNumTxtFld.text!, parkingcount: nil)
            }
        }else{
            self.self.showWarningAlert("Please Enter Staff Count")
        }
    }
    
    func showUpdateCountMsgAlert(msg:String?){
        let alerController = UIAlertController(title: "", message: msg, preferredStyle: .Alert)
        alerController.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {(action:UIAlertAction) in
            self.fetchAllPendingRequest()
            self.timerForGetAllRequest()
        }));
        presentViewController(alerController, animated: true, completion: nil)
    }
    
    func timerForGetAllRequest(){
        _ = NSTimer.scheduledTimerWithTimeInterval(KValetMaangerRequestTimerTime, target: self, selector: Selector("callGetRequestApiDetailsAPI"), userInfo: nil, repeats: true)
    }
    
    func callGetRequestApiDetailsAPI(){
        let serviceManager = ValetServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.fetchAllPendinRequest()
    }
    
    func fetchAllPendingRequest(){
        self.addLoaingIndicator()
        let serviceManager = ValetServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.fetchAllPendinRequest()
    }
    
    
    func cancelRequest(iD : String){
        self.addLoaingIndicator()
        let serviceManager = ValetServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.changeValetStatus(false,iD: iD)
    }
    
    func readyRequest(iD : String){
        self.addLoaingIndicator()
        let serviceManager = ValetServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.changeValetStatus(true, iD: iD)
    }
    
    
    @IBAction func nonMemberButtonClicked(){
        self.addLoaingIndicator()
        let serviceManager = ValetServiceManager()
        serviceManager.managerDelegate = self
        serviceManager.nonMemberRequest()
    }
    
    @IBAction func imageViewCloseBtnClicked(){
        self.imageDetailedConterView.hidden = true
    }


}

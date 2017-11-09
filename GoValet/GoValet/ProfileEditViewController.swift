
//
//  ProfileEditViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 16/01/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit
import TOCropViewController
import DKImagePickerController


extension ProfileEditViewController: WebServiceTaskManagerProtocol {
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        self.removeLoadingIndicator()
        if response.error != nil{
            let errmsg : String = response.error! as String
                self.showAlert("Warning!".localized, message: errmsg)
        }
        else{
            self.carList = UserInfo.currentUser()?.cars
            self.showUserInfo()
            self.carListTable.reloadData()
        }
    }
}

extension ProfileEditViewController : UITableViewDelegate,UITableViewDataSource,AddCarDelegate{
//    CarListCell
    
    func addedCar(){
        self.carList = UserInfo.currentUser()?.cars
        self.carListTable.reloadData()
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 40
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  carList != nil{
            return carList!.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("CarListCell", forIndexPath: indexPath) as! CarListTableViewCell
        cell.car = carList?[indexPath.row]
        cell.showData()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
    }
}

class ProfileEditViewController: UIViewController,TOCropViewControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var profileImageView : UIImageView!
    @IBOutlet weak var fNameTxtFld : CustomTextField!
    @IBOutlet weak var lNameTxtFld : CustomTextField!
    @IBOutlet weak var emailTxtFld : CustomTextField!
    @IBOutlet weak var numberTxtFld : CustomTextField!

    @IBOutlet weak var confirmBtn : UIButton!
    @IBOutlet weak var addCarBtn : UIButton!
    @IBOutlet weak var changePhotoBtn : UIButton!

    @IBOutlet weak var carListTable : UITableView!
    var carList : [Car]?

    private var isImageChanged = false
    var assets: [DKAsset]?
    var isEdited = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLogo()
        self.title = "EDIT ACCOUNT".localized
        self.changeNavTitleColor()
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.Plain, target: self, action: "SignUpViewController.back(_:)")
        self.navigationItem.leftBarButtonItem = newBackButton
        carListTable.tableFooterView = UIView()
        profileImageView.layer.cornerRadius = 15.0
        profileImageView.clipsToBounds = true
        addCarBtn.roundCornerValue(3.0)
//        confirmBtn.roundCornerValue(3.0)
        confirmBtn.layer.borderColor  = UIColor.clearColor().CGColor
        changePhotoBtn.roundCornerValue(3.0)
        fNameTxtFld.roundCorner()
        lNameTxtFld.roundCorner()
        emailTxtFld.roundCorner()
        numberTxtFld.roundCorner()
        self.showUserInfo()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.carList = UserInfo.currentUser()?.cars
        self.carListTable.reloadData()
    }

    func showUserInfo(){
        if let userName = UserInfo.currentUser()?.userFirstName{
            let uname : String = userName
            fNameTxtFld.text = uname
        }
        
        if let userName = UserInfo.currentUser()?.userLastName{
            let uname : String = userName
            lNameTxtFld.text = uname
        }
        if let email = UserInfo.currentUser()?.email{
            emailTxtFld.text = email
        }
        
        if let phone = UserInfo.currentUser()?.phone{
            numberTxtFld.text = phone
        }
        
        if let imageUrl = UserInfo.currentUser()?.profileImage{
//            profileImageView.sd_setImageWithURL(NSURL(string:(imageUrl)))
            profileImageView.sd_setImageWithURL(NSURL(string:(imageUrl)), placeholderImage: UIImage(named: "user"))
        }else{
            profileImageView.image = UIImage(named: "user")
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func back(sender: UIBarButtonItem) {
        if isEdited == true{
            let alerController = UIAlertController(title: "", message: "Are you sure you want to cancel the update?", preferredStyle: .Alert)
            alerController.addAction(UIAlertAction(title: "Ok", style: .Destructive, handler: {(action:UIAlertAction) in
                self.navigationController?.popViewControllerAnimated(true)
            }));
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alerController.addAction(cancelAction)
            presentViewController(alerController, animated: true, completion: nil)
        }else{
            self.navigationController?.popViewControllerAnimated(true)
        }
       
    }
    
    @IBAction func changePhotoBtnClicked(){
        showImagePicker()
    }
    
    
    func showImagePicker(){
        let pickerController = DKImagePickerController()
        //        pickerController.maxSelectableCount = 1
        pickerController.singleSelect = true
        pickerController.showsEmptyAlbums = false
        pickerController.showsCancelButton = true
        self.assets = nil
        pickerController.defaultSelectedAssets = self.assets
        pickerController.didSelectAssets = { (assets: [DKAsset]) in
            self.assets = assets
            //            print("didSelectAssets")
            //            print(assets)
            let asset = self.assets![0]
            asset.fetchOriginalImageWithCompleteBlock({ (image, info) -> Void in
                self.showCropViewController(image!)
            })
        }
        self.presentViewController(pickerController, animated: true) {
            let navigationBarAppearace = UINavigationBar.appearance()
//            navigationBarAppearace.tintColor =  UIColor.blackColor()
//            navigationBarAppearace.barTintColor = UIColor(red:0.13, green:0.14, blue:0.14, alpha:1)
//            navigationBarAppearace.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//            navigationBarAppearace.translucent = true
//            navigationBarAppearace.shadowImage =  UIImage()
            navigationBarAppearace.titleTextAttributes = [
                NSForegroundColorAttributeName: UIColor.blackColor(),
                NSFontAttributeName: UIFont.systemFontOfSize(17)
            ]
        }
    }
    
    func showCropViewController(image:UIImage){
        let cropViewController = TOCropViewController.init(image:image)
        cropViewController.delegate = self
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.setAspectRatioPreset(.PresetSquare, animated: true)
        self.presentViewController(cropViewController, animated: true, completion: nil)
    }
    
    
    func cropViewController(cropViewController: TOCropViewController!, didCropToImage image: UIImage!, withRect cropRect: CGRect, angle: Int)
    {
        cropViewController.dismissViewControllerAnimated(true) { () -> Void in
            self.profileImageView.image = image
            self.isImageChanged = true
        }
    }
    
    func cropViewController(cropViewController: TOCropViewController!, didFinishCancelled cancelled: Bool)
    {
        cropViewController.dismissViewControllerAnimated(true) { () -> Void in  }
    }

    
    
    @IBAction func confrimBtnClicked(){
        let serviceManager = CommonTaskManager()
        serviceManager.managerDelegate = self
        var lname = ""
        var fname = ""
        let email = ""
        let number = ""
        if fNameTxtFld.text?.isBlank == false{
            fname = fNameTxtFld.text!
        }else{
            UtilityMethods.showAlert("Please Enter First Name", tilte: "Warning!".localized, presentVC: self)
            return
        }
        if lNameTxtFld.text?.isBlank == false{
            lname = lNameTxtFld.text!
        }else{
            UtilityMethods.showAlert("Please Enter Last Name", tilte: "Warning!".localized, presentVC: self)
            return
        }
        isEdited = false

        
//        if emailTxtFld.text?.isBlank == false{
//            email = emailTxtFld.text!
//            if Validator.isValidEmail(emailTxtFld.text!) == false{
//                UtilityMethods.showAlert("Please Enter Valide Email", tilte: "Warning!".localized, presentVC: self)
//                return
//            }
//        }else{
//            UtilityMethods.showAlert("Please Enter Email".localized, tilte: "Warning!".localized, presentVC: self)
//            return
//        }
//        
//        if numberTxtFld.text?.isBlank == false{
//            number = numberTxtFld.text!
//        }else{
//            UtilityMethods.showAlert("Please Enter Mobile Number", tilte: "Warning!".localized, presentVC: self)
//            return
//        }
        
        self.addLoaingIndicator()
        if  self.isImageChanged == true{
            serviceManager.updateProfile(email, fname: fname, lname: lname, mobile: number, profileImage: profileImageView.image)
        }else{
            serviceManager.updateProfileInfoWithoutImage(email, fname: fname, lname: lname, mobile: number)
        }
    }
    
    @IBAction func addNewCarBtnClicked(){
        let addCarVC = self.storyboard?.instantiateViewControllerWithIdentifier("AddCarVC") as! AddCarViewController
        addCarVC.delegate = self
        self.navigationController?.pushViewController(addCarVC, animated: true)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool{
        isEdited = true
        return true
    }

}

//
//  PaymentVC.swift
//  GoValet
//
//  Created by Bibin Mathew on 11/11/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum PaymentServiceType {
    case GetSubscriptionList
    case Signup
    case Default
}
class PaymentVC: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var subscriptionCollectionView: UICollectionView!
    @IBOutlet weak var flawLayout: UICollectionViewFlowLayout!
     @IBOutlet weak var subscriptionHeadingLabel: UILabel!
    let cellItemSpacing:CGFloat = 10.0
    var subscriptionListArray = NSArray()
    var selectedSubScription:AnyObject?
    var previousIndex:(NSIndexPath)?
    var selIndex:(NSIndexPath)?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.addLogo()
        self.title = "SUBSCRIPTION".localized
        self.changeNavTitleColor()
        callingGetSubscriptionsApi()
        subscriptionCollectionView.registerNib(UINib(nibName: "SubScriptionCell", bundle: nil), forCellWithReuseIdentifier: "subscriptionCell")
        self.subscriptionHeadingLabel.text = "You are on one month free subscription"
        
        
        
    }
    
    func callingGetSubscriptionsApi(){
        self.addLoaingIndicator()
        
        let token = UserInfo.currentUser()?.token
        var params = [String: AnyObject]()
        params["device_token"] = token
        params["lang"] = "eng"
        postServiceWithApiType(params, type: .GetSubscriptionList)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Collection View Datasources
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriptionListArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let paymentCell:SubScriptionCell = collectionView.dequeueReusableCellWithReuseIdentifier("subscriptionCell", forIndexPath: indexPath) as! SubScriptionCell
        let paymentDetails = self.subscriptionListArray.objectAtIndex(indexPath.row)
        let title:String = paymentDetails["title"] as! String
        let cost:String = paymentDetails["cost"] as! String
        paymentCell.subscriptionLabel.text = title+"\n"+"QAR "+cost
        if selIndex == indexPath{
            paymentCell.setSelectedBorder()
        }
        else{
            paymentCell.setUnSelectedBorder()
        }
        return paymentCell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let paymentDetails = self.subscriptionListArray.objectAtIndex(indexPath.row)
        selectedSubScription = paymentDetails
        if (previousIndex != nil){
            let prevCell:SubScriptionCell = collectionView.cellForItemAtIndexPath(previousIndex!) as! SubScriptionCell
            prevCell.setUnSelectedBorder()
        }
        previousIndex = indexPath
        let subCell:SubScriptionCell = collectionView.cellForItemAtIndexPath(indexPath) as! SubScriptionCell
        subCell.setSelectedBorder()
    }
    
    //MARK: Collection View Delegates
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    func collectionView(collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 0.0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
            return 10.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        print(self.view.frame.width)
        print((self.view.frame.width-3*cellItemSpacing)/2)
        return CGSize(width: (collectionView.frame.width-3*cellItemSpacing)/2, height: 60)
    }
    
    
    
    @IBAction func getButtonAction(sender: AnyObject) {
    }
    
    //Get Subscriptions Api Calling
    
    func postServiceWithApiType(parameters:AnyObject,type:PaymentServiceType){
        var url:(String)?
        if type ==  .GetSubscriptionList{
            url = "\(baseUrl)payment/subscription_list"
        }
        
        Alamofire.request(.POST,url!, parameters: parameters as? [String : AnyObject], headers:nil)
            .validate()
            .responseJSON {response in
                self.removeLoadingIndicator()
                switch response.result{
                case .Success:
                    if let val = response.result.value {
                        print(val)
                        // print("JSON: \(JSON)")
                        self.subscriptionListArray = val["data"] as! NSArray
                        self.subscriptionCollectionView.reloadData()
                        print(self.subscriptionListArray)
                    }
                case .Failure(let error):
                    if let data = response.data, let utf8Text = String.init(data: data, encoding: NSUTF8StringEncoding) {
                        print("Data: \(utf8Text)")
                    }
                    
                }
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

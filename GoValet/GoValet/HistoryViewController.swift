

//
//  HistoryViewController.swift
//  GoValet
//
//  Created by Ajeesh T S on 19/01/17.
//  Copyright © 2017 Ajeesh T S. All rights reserved.
//

import UIKit

extension HistoryViewController: WebServiceTaskManagerProtocol,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func didFinishTask(from manager:AnyObject, response:(data:RestResponse?,error:NSString?)){
        self.removeLoadingIndicator()
        
        //        if response.error != nil{
        //            let errmsg : String = response.error! as String
        //            self.showAlert("Warning!".localized, message: errmsg)
        //            return
        //        }
        print(response.data)
        print(response.error)
        if response.data == nil{
            if(!(response.error == nil)){
                let errmsg : String = response.error! as String
                self.showAlert("Warning!".localized, message: errmsg)
            }
            //            self.successView.hidden = false
            
            
        }else{
            if let managerType = manager as? CommonTaskManager{
                if let historyArray = response.data?.responseModel as? [History] {
                    self.historyList = historyArray
                    self.historyTableView.reloadData()
                }
            }
        }
    }
  
}

class HistoryViewController: UIViewController,UITabBarDelegate,UITableViewDataSource {
    @IBOutlet weak var historyTableView : UITableView!
    var historyList = [History]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLogo()
        self.title = "HISTORY".localized
        self.changeNavTitleColor()
        historyTableView.tableFooterView = UIView()
        getHistoryData()
        // Do any additional setup after loading the view.
    }
    
    func getHistoryData(){
        self.addLoaingIndicator()
        let historyManager = CommonTaskManager()
        historyManager.managerDelegate = self
        historyManager.getHistoryList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 80
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if historyList.count > 0{
            return historyList.count
        }else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell  = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as! HistoryTableViewCell
        cell.history = historyList[indexPath.row]
        cell.showData()
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
    
    }
    


}

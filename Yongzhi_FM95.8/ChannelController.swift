//
//  ChannelController.swift
//  Yongzhi_FM95.8
//
//  Created by Yongzhi on 7/14/16.
//  Copyright © 2016 Yongzhi. All rights reserved.
//

import UIKit
protocol ChannelProtocol {
    func onChangeChannel(channel_id:String)
}
class ChannelController: UIViewController,UITableViewDataSource,UITableViewDelegate {
//    频道列表
    @IBOutlet weak var tv: UITableView!
    
    var channelData:NSArray = NSArray()
    
    var  delegate:ChannelProtocol?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(channelData)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int{

        return channelData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell! {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        cell.textLabel!.text = rowData["name"] as! String
//       cell.detailTextLabel!.text = "detail:\(indexPath.row)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath!){
        var rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        let channel_id:AnyObject? = rowData["channel_id"]
        let channel:String = "channel=\(channel_id!)"
        print("channel\(channel)")
        delegate?.onChangeChannel(channel)
        self.dismissViewControllerAnimated(true, completion: nil)
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

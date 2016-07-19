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
    //频道TableView控件
    @IBOutlet weak var tv: UITableView!
    //频道数据
    var channelData:NSArray = NSArray()
    //遵循ChannelProtocol协议的代理
    var  delegate:ChannelProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //tableView行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return channelData.count
    }
    
    //设置cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "channel")
        //获取选中行的数据
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        //设置tableView标题
        cell.textLabel!.text = rowData["name"] as? String
        return cell
    }
    
    //选中具体频道的操作
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        let rowData:NSDictionary = self.channelData[indexPath.row] as! NSDictionary
        //获取频道id
        let channel_id:AnyObject? = rowData["channel_id"]
        //将其转化为String
        let channel:String = "channel=\(channel_id!)"
        print("channel\(channel)")
        //将频道id传给主界面
        delegate?.onChangeChannel(channel)
        //关闭当前界面
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //设置cell的显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        //设置cell的显示动画为3D缩放
        //xy方向缩放的初始值为0.1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        //设置动画时间为0.25秒，xy方向缩放的最终值为1
        UIView.animateWithDuration(1, animations: {
            cell.layer.transform=CATransform3DMakeScale(1, 1, 1)
        })
    }
}

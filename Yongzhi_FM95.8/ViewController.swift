//
//  ViewController.swift
//  Yongzhi_FM95.8
//
//  Created by Yongzhi on 7/14/16.
//  Copyright © 2016 Yongzhi. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController,HttpProtocol,ChannelProtocol{
    //歌曲封面
    @IBOutlet weak var iv: UIImageView!
    //播放进度条
    @IBOutlet weak var progressView: UIProgressView!
    //播放时间
    @IBOutlet weak var playTime: UILabel!
    //歌曲列表
    @IBOutlet weak var tv: UITableView!
    
    @IBOutlet var tap: UITapGestureRecognizer!
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        if sender.view == btnPlay{
            btnPlay!.hidden = true
            audioPlayer.play()
            btnPlay!.removeGestureRecognizer(tap!)
            iv!.addGestureRecognizer(tap!)
        }else if sender.view == iv{
            btnPlay!.hidden = false
            audioPlayer.pause()
            btnPlay!.addGestureRecognizer(tap!)
            iv!.removeGestureRecognizer(tap!)
        }
    }
    
    @IBOutlet weak var btnPlay: UIImageView?
    //接受歌曲列表
    var tableData:NSArray = NSArray()
    //接受频道列表数据
    var channelData:NSArray = NSArray()
    //获取网络数据类
    var eHttp:HttpController = HttpController()
    //声明字典用作缓存
    var imageCache = Dictionary<String,UIImage>()
    //声明媒体播放控件
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    var timer = NSTimer?()
    


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        iv!.addGestureRecognizer(tap!)
        eHttp.delegate = self
        //       获取频道0的歌曲数据
        eHttp.onSearch("https://www.douban.com/j/app/radio/channels")
        eHttp.onSearch("https://douban.fm/j/mine/playlist?channel=0")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let channelC:ChannelController = segue.destinationViewController as! ChannelController
        channelC.delegate = self
        channelC.channelData = self.channelData
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        UIView.animateWithDuration(0.25, animations: {cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return tableData.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath:NSIndexPath!) -> UITableViewCell! {
//        获取标示为douban的cell
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier: "douban")
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary

//        设置标题
        cell.textLabel!.text = rowData["title"] as? String
//        设置详情
        cell.detailTextLabel!.text = rowData["artist"] as? String
        
        cell.imageView?.image = UIImage(named: "detail.jpg")
//       获取图片地址
        let url = rowData["picture"] as! String
        let image = self.imageCache[url] as UIImage?
        if image == nil{
//       定义NSURL
        let imgURL:NSURL = NSURL(string: url)!
//      定义NSURLRequest
        let request:NSURLRequest = NSURLRequest(URL:imgURL)
//      异步获取图片
        NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue(),completionHandler: {(response:NSURLResponse?,data:NSData?,error:NSError?)->Void in
//            将图片赋予UIImage
            let img = UIImage(data:data!)
//            设置缩略图
            cell.imageView?.image = img
            self.imageCache[url] = img
            })
        }else{
            cell.imageView?.image = image
        }
        return cell
    }
    
    func tableView(tableView :UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
       
        let rowData : NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        let imgUrl:String = rowData["picture"] as! String
        onSetImage(imgUrl)
        
        let audioUrl:String = rowData["url"] as! String
        onSetAudio(audioUrl)
    }

    func didRecieveResults(results: NSDictionary) {
        if (results["song"] != nil){
            self.tableData = results["song"] as! NSArray
            self.tv!.reloadData()
            
            let firDict:NSDictionary = self.tableData[0] as! NSDictionary
            let audioUrl:String = firDict["url"] as! String
            onSetAudio(audioUrl)
            let imgUrl:String = firDict["picture"] as! String
//            print("图片地址\(imgUrl)")
            onSetImage(imgUrl)
        }else if(results["channels"] != nil){
            self.channelData = results["channels"] as! NSArray
//            print(channelData)
        }
        
        
    }
    func onSetImage(url:String){
        let image = self.imageCache[url] as UIImage?
        if image == nil{
        let imgUrl:NSURL = NSURL(string: url)!
        let request:NSURLRequest = NSURLRequest(URL: imgUrl)
        NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue(),completionHandler: {(response:NSURLResponse?,data:NSData?,error:NSError?)->Void in
            let img=UIImage(data:data!)
            self.iv!.image = img
            self.imageCache[url] = img
        })
        }else{
            self.iv!.image = image
        }
    }
    
    func onSetAudio(url:String){
        self.audioPlayer.stop()
        self.audioPlayer.contentURL = NSURL(string:url)
        self.audioPlayer.play()
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime!.text="00:00"
        //开启计时器
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(ViewController.onUpdate), userInfo: nil, repeats: true)
        
        btnPlay!.removeGestureRecognizer(tap!)
        iv!.addGestureRecognizer(tap!)
        btnPlay!.hidden = true
        
    }
    
    func onChangeChannel(channel_id:String) {
        let url:String = "https://douban.fm/j/mine/playlist?type=n&\(channel_id)&from=mainsite"
        print(channel_id)
        eHttp.onSearch(url)
    
    }
    
    func onUpdate(){
        let c = audioPlayer.currentPlaybackTime
        if c>0.0{
            let t = audioPlayer.duration
            let p:CFloat = CFloat(c/t)
            progressView!.setProgress(p, animated: true)
            
            let all:Int = Int(c)
            let m:Int = all%60
            let f:Int = Int(all/60)
            var time:String = ""
            if f<10{
                time="0\(f):"
            }else{
                time="\(f)"
            }
            if m<10{
                time+="0\(m)"
            }else {
                time+="\(m)"
            }
            //更新播放时间
            playTime!.text=time

            
        }
        
    }

}


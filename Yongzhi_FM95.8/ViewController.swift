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
    //播放按钮
    @IBOutlet weak var btnPlay: UIImageView?
    //手势敲击控件
    @IBOutlet var tap: UITapGestureRecognizer!
    
    //获取网络数据类
    var eHttp:HttpController = HttpController()
    //接受歌曲列表
    var tableData:NSArray = NSArray()
    //接受频道列表
    var channelData:NSArray = NSArray()
    //声明字典用作缓存，按地址
    var imageCache = Dictionary<String,UIImage>()
    //声明媒体播放控件
    var audioPlayer:MPMoviePlayerController = MPMoviePlayerController()
    //声明一个计时器
    var timer = NSTimer?()
    //喜欢歌曲列表
    var likeData = Dictionary<String,String>()
    var name = ""
    var likeUrl = ""
    


    override func viewDidLoad() {
        super.viewDidLoad()
        //为HttpController实例设置代理
        eHttp.delegate = self
        //获取歌曲和Channel数据
        eHttp.onSearch("https://douban.fm/j/mine/playlist?type=n&channel=256&from=mainsite")
        eHttp.onSearch("https://www.douban.com/j/app/radio/channels")
//        eHttp.onSearch("https://douban.fm/j/mine/playlist?channel=0")
        //将tap手势注册给iv
        iv!.addGestureRecognizer(tap!)

    }

    //设置cell显示动画
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        //设置cell的显示动画为3D缩放，xy缩放初始值0.1
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
        //设置动画时间为0.25s,xy方向最终值为1
        UIView.animateWithDuration(1, animations: {cell.layer.transform = CATransform3DMakeScale(1, 1, 1)})
    }

    //返回数据行数
    func tableView(tableView: UITableView!, numberOfRowsInSection section:Int) -> Int {
        return tableData.count
    }
    //设置cell
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath:NSIndexPath!) -> UITableViewCell! {
        //获取标示为douban的cell
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle,reuseIdentifier: "douban")
        //获取cell数据
        let rowData:NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //设置标题
        cell.textLabel!.text = rowData["title"] as? String
        //设置详情
        cell.detailTextLabel!.text = rowData["artist"] as? String
        
        
        //获取图片地址
        let url = rowData["picture"] as! String
        //设置缩略图默认图
        cell.imageView?.image = UIImage(named: "detail.jpg")
        //通过图片地址从缓存中取图片
        let image = self.imageCache[url] as UIImage?
        //若缓存没有，则从网络中取得，并缓存
        if image == nil{
            //定义NSURL
            let imgURL:NSURL = NSURL(string: url)!
            //定义NSURLRequest
            let request:NSURLRequest = NSURLRequest(URL:imgURL)
            //异步获取图片
            NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue(),completionHandler: {(response:NSURLResponse?,data:NSData?,error:NSError?)->Void in
                //将图片赋予UIImage
                let img = UIImage(data:data!)
                //设置缩略图
                cell.imageView?.image = img
                //加入缓存
                self.imageCache[url] = img
            })
        }else{
            //缓存中存在，则直接获取
            cell.imageView?.image = image
        }
        return cell
    }
    
    //选择数据行后的响应
    func tableView(tableView :UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        //获取选中行的数据
        let rowData : NSDictionary = self.tableData[indexPath.row] as! NSDictionary
        //获取选中行的图片地址
        let imgUrl:String = rowData["picture"] as! String
        //设置封面图片
        onSetImage(imgUrl)
        //获取歌曲文件地址
        let audioUrl:String = rowData["url"] as! String
        //播放音乐
        onSetAudio(audioUrl)
        name = rowData["title"] as! String
        likeUrl = rowData["url"] as! String

    }
    
    //视图跳转时执行的方法
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //跳转的目标对象为ChannelController类型
        let channelC:ChannelController = segue.destinationViewController as! ChannelController
        //设置跳转对象的代理
        channelC.delegate = self
        //对跳转对象填充频道列表
        channelC.channelData = self.channelData
    }
    


    //实现HttpProtocol协议的方法
    func didRecieveResults(results: NSDictionary) {
        //如果数据的song关键字value不为nil
        if (results["song"] != nil){
            //填充tableData
            self.tableData = results["song"] as! NSArray
            //刷新tableView
            self.tv!.reloadData()
            
            //获取第一首歌的信息
            let firDict:NSDictionary = self.tableData[0] as! NSDictionary
            //获取歌曲文件地址
            let audioUrl:String = firDict["url"] as! String
            name = firDict["title"] as! String
            likeUrl = firDict["url"] as! String
            //播放歌曲
            onSetAudio(audioUrl)
            let imgUrl:String = firDict["picture"] as! String
            //设置ImageView图片
            onSetImage(imgUrl)
            
        //如果channel数据不为nil，则为频道数据
        }else if(results["channels"] != nil){
            self.channelData = results["channels"] as! NSArray
        }
    }
    
    //设置歌曲的封面图
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
    
    //播放歌曲
    func onSetAudio(url:String){
        //展厅当前歌曲的播放
        self.audioPlayer.stop()
        //获取歌曲文件
        self.audioPlayer.contentURL = NSURL(string:url)
        //播放
        self.audioPlayer.play()
        
        //先停掉计时器
        timer?.invalidate()
        //将计时器归零
        playTime!.text="00:00"
        //开启计时器
        timer=NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: #selector(ViewController.onUpdate), userInfo: nil, repeats: true)
        
        //btnPlay移除手势
        btnPlay!.removeGestureRecognizer(tap!)
        //iv重新注册手势
        iv!.addGestureRecognizer(tap!)
        //btnPlay隐藏
        btnPlay!.hidden = true
        
    }
    
    //遵循ChannelProtocol协议所要实现的方法
    func onChangeChannel(channel_id:String) {
        //拼凑歌曲数据网络地址
        let url:String = "https://douban.fm/j/mine/playlist?type=n&\(channel_id)&from=mainsite"
        //获取数据
        eHttp.onSearch(url)
    
    }
    
    //计时器更新方法
    func onUpdate(){
        //返回播放器当前播放时间
        let c = audioPlayer.currentPlaybackTime
        if c>0.0{
            //歌曲总时间
            let t = audioPlayer.duration
            //歌曲播放百分比
            let p:CFloat = CFloat(c/t)
            //通过百分比设置进度条
            progressView!.setProgress(p, animated: true)
            
            //小算法，实现00:00格式播放时间
            let all:Int = Int(c)
            let m:Int = Int(all/60)
            let s:Int = all%60
            var time = ""
            if m<10{
                time="0\(m):"
            }else{
                time="\(m)"
            }
            if s<10{
                time+="0\(s)"
            }else {
                time+="\(s)"
            }
            //更新播放时间
            playTime!.text=time
        }
    }
    
    //响应tap手势
    @IBAction func onTap(sender: UITapGestureRecognizer) {
        //如果当前手势注册对象是btnPlay，隐藏btnPlay，播放歌曲，取消btnPlay的手势，将手势注册给iv
        if sender.view == btnPlay{
            btnPlay!.hidden = true
            audioPlayer.play()
//            btnPlay!.removeGestureRecognizer(tap!)
            iv!.addGestureRecognizer(tap!)
        //反之，若果当前是iv,则显示btnPlay,停止歌曲，取消iv的手势注册，注册个btnPlay
        }else if sender.view == iv{
            btnPlay!.hidden = false
            audioPlayer.pause()
            btnPlay!.addGestureRecognizer(tap!)
//            iv!.removeGestureRecognizer(tap!)
        }
    }
    
    //喜欢操作
    @IBAction func onLike(sender: AnyObject) {
       likeData[name] = likeUrl
        for (key,value) in likeData{
            print("\(key);\(value)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


//
//  HttpController.swift
//  Yongzhi_FM95.8
//
//  Created by Yongzhi on 7/14/16.
//  Copyright © 2016 Yongzhi. All rights reserved.
//

import UIKit

//自定义http协议
    protocol HttpProtocol {
//    定义一个方法接受一个字典
    func didRecieveResults(results:NSDictionary)
    }

class HttpController:NSObject {
//    定义一个可选代理
    var delegate:HttpProtocol?
    
//  定义方法获取网络数据
    func onSearch(url:String){
        //定义一个NSURL
        var nsUrl:NSURL=NSURL(string: url)!
        //定义一个NSURLRequest
        var request:NSURLRequest=NSURLRequest(URL: nsUrl)
        print(request)
        //异步获取数据
        NSURLConnection.sendAsynchronousRequest(request,queue: NSOperationQueue.mainQueue(),completionHandler: {(response:NSURLResponse?,data:NSData?,error:NSError?)->Void in
            //由于我们获取的数据是json格式，所以我们可以将其转化为字典。
            var jsonResult:NSDictionary=try! NSJSONSerialization.JSONObjectWithData(data!,options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
            //将数据传回给代理
//            print(jsonResult)
            self.delegate?.didRecieveResults(jsonResult)
        })
    }
    
}

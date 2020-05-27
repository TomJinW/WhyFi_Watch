//
//  Network.swift
//  WhyFi_Watch WatchKit Extension
//
//  Created by Tom on 2020/5/27.
//  Copyright © 2020 Tom. All rights reserved.
//

//
//  network.swift
//  WhyFiMac
//
//  Created by Tom on 2018/5/27.
//  Copyright © 2018年 Tom. All rights reserved.
//

import Foundation
import SwiftyJSON


class Network{
    static func syncRequest(ip:String,syncURL:String,ansString:String)->(Bool,String){
        var ansrequest = URLRequest(url: URL(string: syncURL)!)
        ansrequest.httpMethod = "POST"
        var success = false
        var message = ""
        let semaphore = DispatchSemaphore(value: 0)
        
        let anspostString = ansString+ip
        ansrequest.httpBody = anspostString.data(using: .utf8)
        URLSession.shared.dataTask(with: ansrequest) { data, response, error in
            //print("TASK BEGIN")
            guard let data = data, error == nil else {
                // ERROR
                message = "未能正确连接到服务器"
                semaphore.signal()
                return
            }
            guard let dataFromString = String(data: data, encoding: .utf8)?.data(using: .utf8, allowLossyConversion: false) else{
                // ERROR
                message = "返回数据格式不正确"
                semaphore.signal()
                return
            }
            //print(String(data: data, encoding: .utf8)!)
            guard let json = try? JSON(data: dataFromString) else {
                // ERROR
                message = "返回数据格式不正确"
                semaphore.signal()
                return
            }
            if json["data"]["portalAuthStatus"] == 1{
                // SUCCESS
                success = true
                semaphore.signal()
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        return (success,message)
    }
    
    static func SendLoginRequest(username:String,password:String,urlString:String,options:String = "")->(Bool,String,String){
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        let postString = "userName=\(username)&password=\(password)\(options)"
        request.httpBody = postString.data(using: .utf8)
        
        let sema = DispatchSemaphore( value: 0)
        var message = ""
        var ip = ""
        var success = false

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // ERROR
                message = "未能正确连接到服务器"
                sema.signal()
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // HTTP ERROR
                message = "HTTP 请求错误，请求返回为：\(httpStatus.statusCode)"
                sema.signal()
                return
            }
            
            guard let dataFromString = String(data: data, encoding: .utf8)?.data(using: .utf8, allowLossyConversion: true) else {
                message = "数据格式有误"
                sema.signal()
                return
            }
            
            guard let json = try? JSON(data: dataFromString) else {
                message = "NOT JSON DATA"
                // NOT JSON DATA
                sema.signal()
                return
            }
            ip = json["data"]["ip"].stringValue
            if json["data"]["accessStatus"] != 200{
                message = "服务器返回错误，消息为：" + json["message"].stringValue
                sema.signal()
            }else{
                success = true
                sema.signal()
            }
        }
        task.resume()
        _ = sema.wait(timeout: DispatchTime.distantFuture)
        return (success,message,ip)
    }
}


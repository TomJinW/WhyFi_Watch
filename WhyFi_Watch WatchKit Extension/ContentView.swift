//
//  ContentView.swift
//  WhyFi_Watch WatchKit Extension
//
//  Created by Tom on 2020/5/27.
//  Copyright © 2020 Tom. All rights reserved.
//

import SwiftUI
import Combine


let url = "https://controller.shanghaitech.edu.cn:8445/PortalServer/Webauth/webAuthAction!login.action"
let options = "&authLan=zh_CN&hasValidateCode=False&validCode=&hasValidateNextUpdatePassword=true&rememberPwd=false&browserFlag=zh&hasCheckCode=false&checkcode=&saveTime=14&autoLogin=false&userMac=&isBoardPage=false"
let syncURL = "https://controller.shanghaitech.edu.cn:8445/PortalServer/Webauth/webAuthAction!syncPortalAuthResult.action"

let ansPostString = "xauthLan=zh_CN&hasValidateCode=False&validCode=&hasValidateNextUpdatePassword=true&rememberPwd=false&browserFlag=zh&hasCheckCode=false&checkcode=&saveTime=14&autoLogin=false&userMac=&isBoardPage=false&browserFlag=zh&clientIp="
struct ContentView: View {
    @ObservedObject var settings = UserSettings()

    @State var userName = ""
    @State var password = ""
    @State var isPresented = false
    @State var isLoginProcess = false
    @State var isSyncingProcess = false

    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var states = 0
    var body: some View {
        Form{
            Section(header:Text("ShanghaiTech").font(.caption),footer: Text("用力按以查看更多选项").font(.footnote).foregroundColor(.secondary)){
                TextField("用户名", text: $settings.username)
                SecureField("密码", text: $settings.password)
                
                Button(action:{
                    self.isLoginProcess = true
                    
                    DispatchQueue.global().async {
//                        sleep(5)
                        
                        let result = Network.SendLoginRequest(username: self.settings.username, password: self.settings.password, urlString: url, options: options)
                        
                        if !result.0{
                            withAnimation {
                                self.isLoginProcess = false
                                self.isSyncingProcess = false
                                self.alertTitle = "错误"
                                self.alertMessage = result.1
                                self.isPresented = true
                            }
                        }else{
                            self.isSyncingProcess = true
                            
                            for i in 0 ..< 10{
                                sleep(3)
                                self.states = i
                                let syncResult = Network.syncRequest(ip: result.2, syncURL: syncURL, ansString: ansPostString)
                                if syncResult.0{
                                    withAnimation{
                                        self.isLoginProcess = false
                                        self.isSyncingProcess = false
                                        self.alertTitle = "连接成功"
                                        self.alertMessage = "ip 地址是\(result.2)"
                                        self.isPresented = true
                                        return
                                    }
                                }
                            }
                            withAnimation{
                               self.isLoginProcess = false
                               self.isSyncingProcess = false
                               self.alertTitle = "错误"
                               self.alertMessage = "连接超时"
                               self.isPresented = true
                               return
                            }
                        }
                    }
                }){
                    HStack{
                        Spacer()
                        Image(systemName: "globe")
                        Text(self.isLoginProcess ? "正在登录 \(isSyncingProcess ? "\(states + 1)":"")" : "登录")
                        Spacer()
                    }
                }
            }

        }.alert(isPresented: $isPresented) {
            Alert(title: Text(alertTitle),message: (Text(alertMessage)))
        }.disabled(isLoginProcess)
        .contextMenu(menuItems: {
             Button(action:{
                   let url = URL(string: "http://www.bing.com")
                   let task = URLSession.shared.dataTask(with: url!) { _, response, _ in
                       if let httpResponse = response as? HTTPURLResponse {
                           if (httpResponse.statusCode == 200){
                               withAnimation{
                                   self.alertTitle = "成功"
                                   self.alertMessage = "http://www.bing.com 连接成功"
                                   self.isPresented = true
                               }
                           }else{
                               withAnimation{
                                   self.alertTitle = "失败"
                                   self.alertMessage = "您可以再试一次"
                                   self.isPresented = true
                               }
                           }
                       }
                   }
                   task.resume()
               }){
                   HStack{
                       Spacer()
                       Image(systemName: "globe")
                       Text("检查网络")
                       Spacer()
                   }
               }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

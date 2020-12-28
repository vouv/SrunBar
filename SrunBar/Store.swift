//
//  Store.swift
//  WeatherBar
//
//  Created by vouv on 2020/12/23.
//  Copyright © 2020 Etsy. All rights reserved.
//

import Cocoa

struct Account {
    var username : String
    var password : String
    var access_token : String
    var acid : Int
}

class Store {
    let accountFile = "account.json"
    
    func getAccount() {
        
    }
    
    func setAccount() {
        
    }
    
    func initAccount() {
        let path = getPath()
        let data: NSData? = NSData.init(contentsOfFile: path)
        
//        NSLog(data?.description)
        
    }
    
    private func getPath() -> String {
        return NSHomeDirectory() + "/.srun/" + accountFile
    }
    
}

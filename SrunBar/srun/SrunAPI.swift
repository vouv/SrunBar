//
//  SrunAPI.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa

enum SrunError : Error {
    case RequestError
}

class SrunAPI {

    let BaseAddr = "http://10.0.0.55"
    let ChallengeUrl = "/cgi-bin/get_challenge"
    let PortalUrl    = "/cgi-bin/srun_portal"
    let InfoUrl = "/cgi-bin/rad_user_info"
    
    let hash = Hash()

    let timeout = TimeInterval.init(2)
    
    func login(username: String, password: String, handle: @escaping (RespLogin?, Error?) -> Void) {
        let (acid, err) = getAcid()
        if let err = err {
            handle(nil, err)
            return
        }
        
        let (respChallenge, errChallenge) = getChallenge(username: username)
        if let err = errChallenge {
            handle(nil, err)
            return
        }
        
        let ch = respChallenge!
        
        let token = ch.challenge
        
        var formLogin = [
            "action":   "login",
            "username": username,
            "password": password,
            "ac_id":    "\(acid)",
            "ip":       ch.clientIP,
            "info":    "",
            "chksum":  "",
            "n":        "200",
            "type":     "1",
        ]
        
        formLogin["info"] = hash.genInfo(formLogin, token)
        formLogin["password"] = hash.pwdHmd5("", token)
        formLogin["chksum"] = hash.checksum(formLogin, token)
                
        self.doRequest(dst: BaseAddr+PortalUrl, params: formLogin, handle: { (res, err) in
            if let err = err {
                handle(nil, err)
            }else if let dict = res {
            
                let resp = RespLogin(
                    checkout_date: dict["checkout_date"] as? String ?? "",
                    online_ip: dict["online_ip"] as? String ?? "",
                    srun_ver: dict["srun_ver"] as? String ?? "",
                    ServicesIntfServerIP: dict["ServicesIntfServerIP"] as? String ?? "",
                    ecode: dict["ecode"] as? String ?? "",
                    ServerFlag: dict["ServerFlag"] as? String ?? "",
                    client_ip: dict["client_ip"] as? String ?? "",
                    ServicesIntfServerPort: dict["ServicesIntfServerPort"] as? String ?? "",
                    res: dict["res"] as? String ?? "",
                    sysver: dict["sysver"] as? String ?? "",
                    username: dict["username"] as? String ?? "",
                    suc_msg: dict["suc_msg"] as? String ?? "",
                    access_token: dict["access_token"] as? String ?? "",
                    error: dict["error"] as? String ?? "",
                    remain_times: dict["remain_times"] as? String ?? "",
                    wallet_balance: dict["wallet_balance"] as? Float ?? 0,
                    error_msg: dict["error_msg"] as? String ?? "",
                    real_name: dict["real_name"] as? String ?? "",
                    remain_flux: dict["remain_flux"] as? String ?? "")
                
                let defaults = UserDefaults.standard
                defaults.setValue(resp.access_token, forKey: "access_token")
                defaults.setValue(resp.client_ip, forKey: "client_ip")
                handle(resp, nil)
            }
        })
    }
    
    func logout(username: String, handle: @escaping (Error?) -> Void) {
        let params = [
            "action":   "logout",
            "username": username,
        ]
        self.doRequest(dst: BaseAddr + PortalUrl, params: params) { (_, error) in
            handle(error)
        }
    }
    
    func info(username: String, password: String, handle: @escaping (RespInfo?, Error?) -> Void) {
        self.doRequest(dst: BaseAddr+InfoUrl, params: nil) { (json, err) in
            if let err = err {
                handle(nil, err)
            }else if let json = json {
                handle(RespInfo(
                        ServerFlag: json["ServerFlag"] as? Int64 ?? 0,
                        add_time: json["add_time"] as? Int64 ?? 0,
                        all_bytes: json["all_bytes"]as? Int64 ?? 0,
                        bytes_in: json["bytes_in"] as? Int64 ?? 0,
                        bytes_out: json["bytes_out"] as? Int64 ?? 0,
                        checkout_date: json["checkout_date"] as? Int64 ?? 0,
                        domain: json["domain"] as? String ?? "",
                        error: json["error"] as? String ?? "",
                        group_id: json["group_id"]as? String ?? "",
                        keepalive_time: json["keepalive_time"]as? Int64 ?? 0,
                        online_ip: json["online_ip"]as? String ?? "",
                        products_name: json["products_name"]as? String ?? "",
                        real_name: json["real_name"]as? String ?? "",
                        remain_bytes: json["remain_bytes"]as? Int64 ?? 0,
                        remain_seconds: json["remain_seconds"]as? Int64 ?? 0,
                        sum_bytes: json["sum_bytes"]as? Int64 ?? 0,
                        sum_seconds: json["sum_seconds"]as? Int64 ?? 0,
                        user_balance: json["user_balance"]as? Float64 ?? 0,
                        user_charge: json["user_charge"]as? Float64 ?? 0,
                        user_mac: json["user_mac"] as? String ?? "",
                        user_name: json["user_name"] as? String ?? "",
                        wallet_balance: json["wallet_balance"] as? Float64 ?? 0), err)
            }
        }
    }
    
    func getChallenge(username : String) -> (RespChallenge?, Error?) {
        var resp : RespChallenge?
        var err : Error?
        let semaphore = DispatchSemaphore.init(value: 0)
        
        self.doRequest(dst: BaseAddr + ChallengeUrl,
            params: ["username": username, "ip":""]) { (json, error) in
            if let error = error {
                err = error
            }else if let json = json {
                resp = RespChallenge(
                    challenge: json["challenge"] as! String,
                    clientIP: json["client_ip"] as! String,
                    onlineIP: json["online_ip"] as! String,
                    res: json["res"] as! String,
                    ecode: json["ecode"] as! Int,
                    error: json["error"] as! String,
                    errorMsg: json["error_msg"] as! String,
                    srunVersion: json["srun_ver"] as! String,
                    expire: json["expire"] as! String,
                    st: json["st"] as! Int)
            }
            semaphore.signal()
        }
        semaphore.wait()
        return (resp, err)
    }
    
    private func getAcid() -> (Int, Error?) {
  
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = self.timeout
        let session = URLSession(configuration: config)

        let semaphore = DispatchSemaphore.init(value: 0)
        var acid = 1
        var err : Error?
        let task = session.dataTask(
            with: URL(string: BaseAddr)!,
            completionHandler:  { (data, response, error) in
                if let error = error {
                    err = error
                }else if let response = response {
                    let query = response.url?.query ?? ""
                    if query.contains("ac_id=") {
                        let range = query.range(of: "ac_id=")!
                        let end = query.index(range.upperBound, offsetBy: 1)
                        acid = Int(query[range.upperBound..<end]) ?? 1
                    }
                }
 
                // 通知
                semaphore.signal()
            })
        task.resume()
        semaphore.wait()
        return (acid, err)
    }
        
    func doRequest(dst: String, params: [String: String]?, handle: @escaping ([String:AnyObject]?, Error?) -> Void) {
        var addr = URLComponents(string: dst)!
        // param
        var query = [URLQueryItem]()
        
        let queryCallback = self.genCallback();
        
        query.append(URLQueryItem(name: "callback", value: queryCallback))
        query.append(URLQueryItem(name: "_", value: self.genMillStamp()))
        
        if let params = params {
            for (key,value) in params {
                query.append(URLQueryItem(name: key, value: value))
            }
        }

        query = query.filter{!$0.name.isEmpty}

        addr.queryItems = query
        
        // encode + 和 /
        addr.percentEncodedQuery = addr.percentEncodedQuery?
            .replacingOccurrences(of: "+", with:"%2B")
        .replacingOccurrences(of: "/", with:"%2F")
        
        var urlRequest = URLRequest(url: addr.url!)
        urlRequest.httpMethod = "GET"
                
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        let session = URLSession(configuration: config)
        let task = session.dataTask(
            with: urlRequest,
            completionHandler: { (data, response, error) in
                
                if let error = error {
                    handle(nil, error)
                    return
                }

                let body = String(data: data!, encoding: String.Encoding.utf8)!

                if body.count < queryCallback.count {
                    handle(nil, SrunError.RequestError)
                    return
                }

                let startIndex = body.index(body.startIndex, offsetBy: queryCallback.count+1)
                let endIndex = body.index(body.endIndex, offsetBy: -1)
                            
                let jsonStr = body[startIndex..<endIndex].data(using: String.Encoding.utf8)
                
                typealias JSONDict = [String:AnyObject]
                let json : JSONDict
                
                do {
                    json = try JSONSerialization.jsonObject(with: jsonStr!, options: []) as! JSONDict
                    handle(json, nil)
                } catch {
                    NSLog("JSON parsing failed: \(error)")
                    handle(nil, error)
                    return
                }
        })

        task.resume()
    }
    
    func genCallback()  -> String {
        return "jsonp\(Date().milliStamp)"
    }
    func genMillStamp()  -> String {
        return "\(Date().milliStamp)"
    }
}

extension Date {

    /// 获取当前 秒级 时间戳 - 10位
    var timeStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return "\(timeStamp)"
    }

    /// 获取当前 毫秒级 时间戳 - 13位
    var milliStamp : String {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        let millisecond = CLongLong(round(timeInterval*1000))
        return "\(millisecond)"
    }
}


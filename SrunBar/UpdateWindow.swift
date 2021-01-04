//
//  UpdateWindow.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa

class UpdateWindow: NSWindowController, NSWindowDelegate {
    
    @IBOutlet weak var progressBar: NSProgressIndicator!
    
    override var windowNibName : String! { "UpdateWindow" }
    
    var task : URLSessionTask!
    
    let titleNewVersion = "发现新版本"
    let titleUpdateError = "更新错误"
    let titleUpToDate = "无需更新"
    
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.progressBar.startAnimation(nil)
           
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        self.task = self.requestTask()
        DispatchQueue.global().async {
            self.task.resume()
        }
    }
        
    func requestTask() -> URLSessionTask {
        let timeout = TimeInterval.init(10)
        let dst = "https://github.com/vouv/SrunBar/releases/latest"
        
        let addr = URLComponents(string: dst)!
        var urlRequest = URLRequest(url: addr.url!)
        urlRequest.httpMethod = "GET"
                
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        let session = URLSession(configuration: config)
        let task = session.dataTask(
            with: urlRequest,
            completionHandler: { (data, response, error) in
                DispatchQueue.main.async {
                    self.window?.close()
                }
                var errInfo = ""
                if let error = error {
                    errInfo = error.localizedDescription
                }else if let response = response {
                    let target = response.url?.absoluteString ?? ""

                    let base = "https://github.com/vouv/SrunBar/releases/tag/"
                    if target.contains(base) {
                        let startIndex = target.index(target.startIndex, offsetBy: base.count)
                        let newVersion = String(target[startIndex..<target.endIndex])
                        let currentVersion = self.getCurrentVersion()

                        if self.compareVersion(current: currentVersion, remote: newVersion) {
                            DispatchQueue.main.async {
                                let alt = NSAlert.init()
                                alt.messageText = self.titleNewVersion + newVersion
                                alt.informativeText = "当前版本 " + currentVersion
                                let btn = alt.addButton(withTitle: "前往更新")
                                btn.target = self
                                btn.action = #selector(self.openVersionUrl)
                                let btnCancel = alt.addButton(withTitle: "稍后")
                                btnCancel.target = self
                                btnCancel.action = #selector(self.stopModal)
                                alt.runModal()
                            }
                        }else {
                            DispatchQueue.main.async {
                                let alt = NSAlert.init()
                                alt.messageText = self.titleUpToDate
                                alt.informativeText = currentVersion + " 是最新版本"
                                alt.runModal()
                            }
                        }
                        return
                    }
                    errInfo = "版本解析失败, 请联系开发者"
                }
                DispatchQueue.main.async {
                    let alt = NSAlert.init()
                    alt.messageText = self.titleUpdateError
                    alt.informativeText = errInfo
                    alt.runModal()
                }
            })
        return task
    }
    
    // 关闭请求
    func windowWillClose(_ notification: Notification) {
        self.task.cancel()
    }
    
    func getCurrentVersion() -> String {
        let def = UserDefaults.standard
        return def.string(forKey: "version") ?? ""
    }
    
    func compareVersion(current:String, remote:String) -> Bool {
        // 先去掉v
        let nowVersion = String(current[current.index(current.startIndex, offsetBy: 1)..<current.endIndex])
        let newVersion = String(remote[remote.index(remote.startIndex, offsetBy: 1)..<remote.endIndex])
        let nowArray = nowVersion.split(separator: ".")
        
        let newArray = newVersion.split(separator: ".")
        
        let big = nowArray.count > newArray.count ? newArray.count : nowArray.count
        
        for index in 0...big - 1 {
            let first = nowArray[index]
            let second = newArray[index]
            if Int(first)! < Int(second)!  {
                return true
            }
        }
        return false
    }
    
    @objc func stopModal(_ sender: NSButton) {
        NSApp.stopModal()
    }

    @objc func openVersionUrl(_ sender: NSButton) {
        // 关闭弹窗
        NSApp.stopModal()
        
        let link = "https://github.com/vouv/SrunBar/releases/latest"
        
        let url = URL(string: link)
        DispatchQueue.global().async {
            NSWorkspace.shared.open(url!)
        }
    }
}

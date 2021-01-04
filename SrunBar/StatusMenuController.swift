//
//  StatusMenuController.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa

enum SrunStatus : Int {
    case connected = 1
    case unKnown = 2
    case ready = 3
}


class StatusMenuController: NSObject, NSMenuDelegate {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var infoView: InfoView!
    
    var srunMenuItem: NSMenuItem!
    
    var configWindow: ConfigWindow!
    var aboutWindow: AboutWindow!
    var updateWindow: UpdateWindow!
    
    @IBOutlet weak var statusMenuItem: NSMenuItem!
//    @IBOutlet weak var loginItem: NSMenuItem!
//
//    @IBOutlet weak var aboutItem: NSMenuItem!
    
    var statusIcon: NSImage? {
        let icon = NSImage(named: "statusIcon")
        // best for dark mode
        icon?.isTemplate = true
        return icon
    }

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let srun = SrunAPI()
    
    var srunStatus = SrunStatus.connected
    let srunStatusText = [
        SrunStatus.connected: "已联网",
        SrunStatus.ready: "未登录",
        SrunStatus.unKnown: "未知网络",
    ]
    let srunStatusImage = [
        SrunStatus.connected: NSImage(named: "NSStatusAvailable")!,
        SrunStatus.ready: NSImage(named: "NSStatusPartiallyAvailable")!,
        SrunStatus.unKnown: NSImage(named: "NSStatusNone")!,
    ]
    
    override func awakeFromNib() {
        statusItem.menu = statusMenu
        // 监听显示事件
        statusMenu.delegate = self
        
        statusItem.button?.image = statusIcon
        
        srunMenuItem = statusMenu.item(withTitle: "Info")
        srunMenuItem.view = infoView
        
        // 两个基本页面
        configWindow = ConfigWindow()
        aboutWindow = AboutWindow()
        updateWindow = UpdateWindow()
        
        // 注册监听
        NotificationCenter.default.addObserver(forName: NSNotification.Name("login"), object: nil, queue: nil) { (notice) in
//            debugPrint("login")
            self.doLogin()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("logout"), object: nil, queue: nil) { (notice) in
//            debugPrint("logout")
            self.doLogout()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name("info"), object: nil, queue: nil) { (notice) in
//            debugPrint("info")
            self.doInfo()
        }
    }
        
    func doLogin() {
        let defaults = UserDefaults.standard
        guard let username = defaults.string(forKey: "username") else {
            return
        }
        guard let password = defaults.string(forKey: "password") else {
            return
        }
        srun.login(username: username, password: password) { (res, err) in
            if let err = err {
                self.notify(title: "登录失败", subtitle: err.localizedDescription)
            }else if let res = res {
                if res.access_token.count > 0 {
                    self.notify(title: "登录成功", subtitle: "账号:\(res.username)")
                }else if res.error_msg.contains("Arrearage users") {
                    self.notify(title: "已欠费", subtitle: "登录失败")
                }else {
                    self.notify(title: "登录异常", subtitle: "\(res.error_msg)")
                }
            }else {
                self.notify(title: "登录失败", subtitle: "未知Bug")
            }
        }
    }
    
    func doLogout() {
        let defaults = UserDefaults.standard
        guard let username = defaults.string(forKey: "username") else {
            self.notify(title: "错误", subtitle: "请先设置用户名密码")
            return
        }
        
        srun.logout(username: username) { (err) in
            if let err = err {
                self.notify(title: "注销失败", subtitle: err.localizedDescription)
                self.setSrunStatus(.unKnown)

            }else {
                self.notify(title: "注销成功", subtitle: "账号\(username)")
                self.setSrunStatus(.ready)
                return
            }
        }
    }
    
    func doInfo() {
        let defaults = UserDefaults.standard
        guard let username = defaults.string(forKey: "username") else {
            return
        }
        guard let password = defaults.string(forKey: "password") else {
            return
        }
        srun.info(username: username, password: password) { (res, error) in
            if error != nil {
                
            }else if let info = res {
                // 如未登录，返回数据为空
                if info.user_name == username {
                    DispatchQueue.main.async {
                        self.setSrunStatus(.connected)
                        self.infoView.update(info)
                    }
                }else {
                    self.setSrunStatus(.ready)
                }
                return
            }
            self.setSrunStatus(.unKnown)
        }
    }
    
    func setSrunStatus(_ status: SrunStatus) {
        DispatchQueue.main.async {
            self.srunStatus = status
            self.statusMenuItem.title = self.srunStatusText[self.srunStatus] ?? ""
            self.statusMenuItem.image = self.srunStatusImage[self.srunStatus]
        }
    }

    // 打开view自动更新info
    func menuWillOpen(_ menu: NSMenu) {
        DispatchQueue.global().async(){
            NotificationCenter.default.post(name: NSNotification.Name("info"), object: nil)
        }
    }

    @IBAction func loginClicked(_ sender: NSMenuItem) {
        DispatchQueue.global().async(){
            NotificationCenter.default.post(name: NSNotification.Name("login"), object: nil)
        }
    }
    
    @IBAction func logoutClicked(_ sender: NSMenuItem) {
        DispatchQueue.global().async(){
            NotificationCenter.default.post(name: NSNotification.Name("logout"), object: nil)
        }
    }

    private func notify(title: String, subtitle: String) {
        let nty = NSUserNotification.init()
        nty.title = title
        nty.subtitle = subtitle
//        nty.hasActionButton = false
        nty.actionButtonTitle = "关闭"
        
        NSUserNotificationCenter.default.scheduleNotification(nty)
    }
    
    @IBAction func configClicked(_ sender: NSMenuItem) {
        self.configWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func aboutClicked(_ sender: NSMenuItem) {
        self.aboutWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
        
    @IBAction func updateClicked(_ sender: NSMenuItem) {
        self.updateWindow.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
}

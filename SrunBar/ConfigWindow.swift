//
//  ConfigWindow.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa


class ConfigWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    
    override var windowNibName : String! { "ConfigWindow" }
    
    @IBAction func saveClicked(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        let username = usernameField.stringValue
        let password = passwordField.stringValue
        defaults.setValue(username, forKey: "username")
        defaults.setValue(password, forKey: "password")

        if username != "" && password != "" {
            // 执行登录
            DispatchQueue.global().async(){
                NotificationCenter.default.post(name: NSNotification.Name("login"), object: nil)
            }
        }
        self.window?.close()
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        let defaults = UserDefaults.standard
        usernameField.stringValue = defaults.string(forKey: "username") ?? ""
        passwordField.stringValue = defaults.string(forKey: "password") ?? ""
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
}

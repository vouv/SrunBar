//
//  AboutWindow.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa

class AboutWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var versionLabel: NSTextField!
    
    let version = UserDefaults.standard.string(forKey: "version") ?? ""

    let link = "https://github.com/vouv/SrunBar"

    override var windowNibName : String! { "AboutWindow" }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        debugPrint("load about")
        versionLabel?.stringValue = "SrunBar " + version
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
        
    @IBAction func linkClicked(_ sender: NSButtonCell) {
        let url = URL(string: link)
        NSWorkspace.shared.open(url!)
    }

}

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
    
    let version = "v0.2.8"
    let link = "https://github.com/vouv/SrunBar"

    override var windowNibName : String! { "AboutWindow" }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.versionLabel?.stringValue = "SrunBar " + version
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func linkClicked(_ sender: NSButtonCell) {
        let url = URL(string: link)
        NSWorkspace.shared.open(url!)
    }

}

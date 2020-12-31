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
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window?.center()
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        self.progressBar.startAnimation(nil)
    }
    
    func windowWillClose(_ notification: Notification) {
        
    }
    
}

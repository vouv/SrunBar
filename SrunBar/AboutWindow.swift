
import Cocoa

class AboutWindow: NSWindowController, NSWindowDelegate {

    @IBOutlet weak var versionLabel: NSTextField!
    
    let version = "v0.2.7"
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

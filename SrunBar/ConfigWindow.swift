
import Cocoa

protocol PreferencesWindowDelegate {
    func preferencesDidUpdate()
}

class ConfigWindow: NSWindowController, NSWindowDelegate {
//    var delegate: PreferencesWindowDelegate?

    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var passwordField: NSSecureTextField!
    
    @IBOutlet weak var saveButton: NSButton!
    
    override var windowNibName : String! { "ConfigWindow" }
    
    @IBAction func saveClicked(_ sender: NSButton) {
        let defaults = UserDefaults.standard
        defaults.setValue(usernameField.stringValue, forKey: "username")
        defaults.setValue(passwordField.stringValue, forKey: "password")
//        delegate?.preferencesDidUpdate()
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

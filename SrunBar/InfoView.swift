
import Cocoa

class InfoView: NSView {
    @IBOutlet weak var IPField: NSTextField!
    @IBOutlet weak var usernameField: NSTextField!
    @IBOutlet weak var walletField: NSTextField!
    @IBOutlet weak var balanceField: NSTextField!
    @IBOutlet weak var volumeField: NSTextField!
    @IBOutlet weak var onlineTimeField: NSTextField!
    
    func update(_ info: RespInfo) {
        DispatchQueue.main.async {
            // 只能在主线程更新UI
            self.IPField.stringValue = info.online_ip
            self.usernameField.stringValue = info.user_name
            self.walletField.stringValue = String.init(format: "%.2f 元", info.wallet_balance)
            self.balanceField.stringValue = String.init(format: "%.2f 元", info.user_balance)
            self.volumeField.stringValue = self.parseBytes(info.sum_bytes)
            self.onlineTimeField.stringValue = self.parseSeconds(info.sum_seconds)
        }
    }
    
    private func parseBytes(_ bytes: Int64) -> String {
        let KB: Double = 1024
        let MB = KB * 1024
        let GB = MB * 1024
        let gb = Double(bytes) / GB
        if gb > 0 {
            return String.init(format: "%.2f GB", gb)
        }
        let mb = Double(bytes) / MB
        return String.init(format: "%.1f MB", mb)
    }
    
    private func parseSeconds(_ seconds: Int64) -> String {
        let hour : Int64 = 3600
        let hours = seconds / hour
        let minutes = (seconds%3600) / 60
        if hours > 0 {
            return String.init(format: "%d小时", hours)
        }
        return String.init(format: "%d分钟", minutes)
    }
}

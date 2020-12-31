//
//  Hash.swift
//  SrunBar
//
//  Created by vouv on 2021/1/1.
//  Copyright © 2021 Vouv. All rights reserved.
//

import Cocoa
import CryptoKit

class Hash {
    private func charCodeAt(_ str: String, _ index:Int) -> Int {
        let cs = str.utf8
        if index >= cs.count {
            return 0
        }
        let cIndex = cs.index(cs.startIndex, offsetBy: index)
        return Int(cs[cIndex])
    }

    private func code2char(_ code: Int) -> Character {
        return Character.init(Unicode.Scalar(code)!)
    }

    private func s(_ a: String, _ b: Bool) -> [Int] {
        let c = a.count
        var v = [Int]()
        for i in stride(from: 0, to: c, by: 4) {
            let tmp = charCodeAt(a, i) |
                (charCodeAt(a, i+1) << 8) |
                (charCodeAt(a, i+2) << 16) |
                (charCodeAt(a, i+3) << 24)
            v.append(tmp)
        }
        if b {
            v.append(c)
        }
        return v
    }

    private func l(_ a: [Int], _ b: Bool) -> String {
        let d = a.count
        var c = (d - 1) << 2
        if b {
            let m = a[d-1]
            if m < c-3 || m > c {
                return ""
            }
            c = m
        }
        var res = [String]()
        
        for s in a {
            let item = "\(code2char(s&0xff))\(code2char((s>>8)&0xff))\(code2char((s>>16)&0xff))\(code2char((s>>24)&0xff))"
            res.append(item)
        }
        
        if b {
            return res[0..<c].joined()
        } else {
            return res.joined()
        }

    }

    // x encode
    private func xEncode(_ msg: String, _ key: String) -> String {
        if msg == "" {
            return ""
        }
        var v = s(msg, true)
        let k = s(key, false)
        let n = v.count - 1
        var z = Int(v[n])
        var y = v[0]
        let c = 0x86014019 | 0x183639A0
        var m  = 0
        var e = 0

        var d  = 0
        let q = 6 + 52/(n+1)
        
        for _ in stride(from: q, to: 0, by: -1)  {
            d = (d + c) & (0x8CE0D9BF | 0x731F2640)
            e = d >> 2 & 3
            for p in 0..<n {
                y = v[p+1]
                m = z>>5 ^ y<<2
                m += (y>>3 ^ z<<4) ^ (d ^ y)
                m += k[(p&3)^e] ^ z
                v[p] = (v[p] + m) & (0xEFB8D130 | 0x10472ECF)
                z = v[p]
            }
            y = v[0]
            m = z>>5 ^ y<<2
            m += (y>>3 ^ z<<4) ^ (d ^ y)
            m += k[(n&3)^e] ^ z
            v[n] = (v[n] + m) & (0xBB390742 | 0x44C6F8BD)
            z = v[n]
        }
        return l(v, false)
    }
    
    func pwdHmd5(_ password: String, _ token: String) -> String {
        
        let dataToken = token.data(using: String.Encoding.utf8)!
        let dataPassword = password.data(using: String.Encoding.utf8)!
        
        // for macOS 10.15+
        var hm = HMAC<Insecure.MD5>.init(key: SymmetricKey.init(data: dataToken))
        
        hm.update(data: dataPassword)
        
        let hmd5 = hm.finalize().description
        
        let startIndex = hmd5.index(hmd5.startIndex, offsetBy: "HMAC with MD5: ".count)
        
        return "{MD5}\(hmd5[startIndex..<hmd5.endIndex])"
    }
    
    // sha1 sum
    func checksum(_ data: [String:String], _ token: String) -> String {
        let username = data["username"] ?? ""
        let password = data["password"] ?? ""
        let acid = data["ac_id"] ?? ""
        let ip = data["ip"] ?? ""
        let info = data["info"] ?? ""

        let strList: [String] = [
            "",
            username,
            String(password[password.index(password.startIndex, offsetBy: 5)..<password.endIndex]),
            acid, ip, "200", "1",
            info,
        ]

        let sumStr = strList.joined(separator: token)
        
        var sh = Insecure.SHA1.init()

        sh.update(data: sumStr.data(using: String.Encoding.utf8)!)

        let hsh = sh.finalize().description
        
        let startIndex = hsh.index(hsh.startIndex, offsetBy: "SHA1 digest: ".count)

        return String(hsh[startIndex..<hsh.endIndex])
    }
    
    // 加密信息
    func genInfo(_ data: [String:String], _ token: String) -> String {
        let dictKey = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="
        let dictVal = "LVoJPiCN2R8G90yg+hmFHuacZ1OWMnrsSTXkYpUq/3dlbfKwv6xztjI7DeBE45QA="
        var dict = [String:String]()
        
        for (idx, c) in dictKey.enumerated() {
            dict["\(c)"] = "\(dictVal[dictVal.index(dictVal.startIndex, offsetBy: idx)])"
        }
        
        let xEncodeJson: [String:String] = [
            "username": data["username"] ?? "",
            "password": data["password"] ?? "",
            "ip":       data["ip"] ?? "",
            "acid":     data["ac_id"] ?? "",
            "enc_ver":  "srun_bx1",
        ]

        let xEncodeRaw = try! JSONSerialization.data(withJSONObject: xEncodeJson, options: JSONSerialization.WritingOptions.sortedKeys)
        
        let xen = String(data:xEncodeRaw,encoding:.utf8)!
        
        let xEncodeRes = xEncode(xen, token)
        
        // 这里不用utf8字节数组算
        let b64Arr = xEncodeRes.unicodeScalars.map { UInt8($0.value) }

        let b64Res = Data(b64Arr).base64EncodedString()
        
        var target = ""
        for s in b64Res {
            target += dict["\(s)"] ?? ""
        }
        
        return "{SRBX1}" + target
    }

}

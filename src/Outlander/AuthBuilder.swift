//
//  AuthBuilder.swift
//  Outlander
//
//  Created by Joseph McBride on 4/9/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class AuthBuilder : NSObject {
    
    class func newInstance() -> AuthBuilder {
        return AuthBuilder()
    }
    
    func build(_ account:String, hash: Data) -> Data {
        let data = NSMutableData()
        
        data.appendByte(0x41) // A
        data.appendByte(0x09) // tab
        
        let accountData = account.data(using: String.Encoding.utf8, allowLossyConversion: true)
        
        data.append((accountData! as NSData).bytes, length: accountData!.count)
        data.appendByte(0x09) // tab
        
        data.append((hash as NSData).bytes, length: hash.count)
        
        data.appendByte(0x0A) // newline
        
        return data as Data
    }
}

extension NSMutableData {
    
    func appendByteArray(_ bytes: [UInt8]) {
        for b in bytes {
            self.appendByte(b)
        }
    }
    
    func appendByte(_ b: UInt8) {
        var b2 = b
        self.append(&b2, length: 1)
    }
}

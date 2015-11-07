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
    
    func build(account:String, hash: NSData) -> NSData {
        let data = NSMutableData()
        
        data.appendByte(0x41) // A
        data.appendByte(0x09) // tab
        
        let accountData = account.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        data.appendBytes(accountData!.bytes, length: accountData!.length)
        data.appendByte(0x09) // tab
        
        data.appendBytes(hash.bytes, length: hash.length)
        
        data.appendByte(0x0A) // newline
        
        return data
    }
}

extension NSMutableData {
    
    func appendByteArray(let bytes: [UInt8]) {
        for b in bytes {
            self.appendByte(b)
        }
    }
    
    func appendByte(var b: UInt8) {
        self.appendBytes(&b, length: 1)
    }
}
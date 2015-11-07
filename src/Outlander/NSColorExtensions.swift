//
//  NSColorExtensions.swift
//  Outlander
//
//  Created by Joseph McBride on 4/1/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

extension NSColor {
    
    convenience init(hex:String) {
        var str = hex
        if(str.hasPrefix("#")) {
            str = hex.substringFromIndex(hex.startIndex.advancedBy(1))
        }
        var rgbValue:UInt32 = 0
        NSScanner(string: str).scanHexInt(&rgbValue)
        
        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
    
    func getHexString() -> String {
        let red = Int(round(self.redComponent * 0xFF))
        let grn = Int(round(self.greenComponent * 0xFF))
        let blu = Int(round(self.blueComponent * 0xFF))
        let hexString = NSString(format: "#%02X%02X%02X", red, grn, blu)
        return hexString as String
    }
}
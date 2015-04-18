//
//  TDPUpdateHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/17/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TDPUpdateHandler {
    
    class func newInstance() -> TDPUpdateHandler {
        return TDPUpdateHandler()
    }
    
    func handle(nodes:[Node], text:String, context:GameContext) {
        var groups = text["Time Development Points: (\\d+)"].groups()
        
        if groups.count > 1 {
            context.globalVars.setCacheObject(groups[1], forKey: "tdp")
        } else {
            groups = text["TDPs : (\\d+)"].groups()
            if groups.count > 1 {
                context.globalVars.setCacheObject(groups[1], forKey: "tdp")
            }
        }
    }
}
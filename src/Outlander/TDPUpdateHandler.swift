//
//  TDPUpdateHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/17/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class TDPUpdateHandler : NSObject {
    
    class func newInstance() -> TDPUpdateHandler {
        return TDPUpdateHandler()
    }
    
    func handle(_ nodes:[Node], text:String, context:GameContext) {
        for group in text["Time Development Points: (\\d+)"] {
            context.globalVars.setCacheObject(group[1]!, forKey: "tdp")
        }
        
        for group in text["TDPs : (\\d+)"] {
            context.globalVars.setCacheObject(group[1]!, forKey: "tdp")
        }
    }
}

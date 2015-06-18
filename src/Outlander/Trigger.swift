//
//  Trigger.swift
//  Outlander
//
//  Created by Joseph McBride on 6/5/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

public class Trigger : NSObject {
    var trigger:String
    var action:String
    var actionClass:String
    
    init(_ trigger:String, _ action:String, _ actionClass:String) {
        self.trigger = trigger
        self.action = action
        self.actionClass = actionClass
    }
}
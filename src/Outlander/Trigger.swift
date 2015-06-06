//
//  Trigger.swift
//  Outlander
//
//  Created by Joseph McBride on 6/5/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

class Trigger {
    var trigger:String
    var action:String
    var className:String
    
    init(_ trigger:String, _ action:String, _ className:String) {
        self.trigger = trigger
        self.action = action
        self.className = className
    }
}
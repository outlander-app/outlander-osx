//
//  Substitute.swift
//  Outlander
//
//  Created by Joseph McBride on 4/3/16.
//  Copyright © 2016 Joe McBride. All rights reserved.
//

import Foundation

public class Substitute : NSObject {
    var pattern:String?
    var action:String?
    var actionClass:String?
    
    init(_ pattern:String, _ action:String, _ actionClass:String) {
        self.pattern = pattern
        self.action = action
        self.actionClass = actionClass
    }
}
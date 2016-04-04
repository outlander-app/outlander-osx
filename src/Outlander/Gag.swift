//
//  Gag.swift
//  Outlander
//
//  Created by Joseph McBride on 6/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

class Gag : NSObject {
    var pattern:String?
    var patternClass:String?
    
    init(_ pattern:String, _ patternClass:String) {
        self.pattern = pattern
        self.patternClass = patternClass
    }
}
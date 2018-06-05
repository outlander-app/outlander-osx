//
//  Clock.swift
//  Outlander
//
//  Created by Joseph McBride on 6/4/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

@objc
public protocol IClock {
    var now:NSDate { get }
}

@objc
public class Clock : NSObject, IClock {

    private var get:()->NSDate

    override convenience init() {
        self.init({ NSDate() })
    }

    init(_ get:()->NSDate) {
        self.get = get
    }
    
    public var now:NSDate {
        return self.get()
    }
}

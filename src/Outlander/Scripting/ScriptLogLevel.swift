//
//  ScriptLogLevel.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

public enum ScriptLogLevel : Int {
    case None = 0
    case Gosubs = 1
    case Wait = 2
    case If = 3
    case Vars = 4
    case Actions = 5
}

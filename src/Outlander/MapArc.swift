//
//  MapArc.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

public class MapArc {
    var exit:String
    var move:String
    var destination:String
    var hidden:Bool
    
    init(exit:String, move:String, destination:String, hidden:Bool){
        self.exit = exit
        self.move = move
        self.destination = destination
        self.hidden = hidden
    }
}
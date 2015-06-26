//
//  GagLoader.swift
//  Outlander
//
//  Created by Joseph McBride on 6/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class GagsLoader {
    
    class func newInstance(context:GameContext, fileSystem:FileSystem) -> GagsLoader {
        return GagsLoader(context: context, fileSystem: fileSystem)
    }
    
    var context:GameContext
    var fileSystem:FileSystem

    init(context:GameContext, fileSystem:FileSystem) {
        self.context = context
        self.fileSystem = fileSystem
    }
    
    func load() {
    }
    
    func save() {
    }
}
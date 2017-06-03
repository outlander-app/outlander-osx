//
//  Matches.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

protocol IMatch {
    var value:String {get}
    var label:String {get}
    var groups:[String] {get}

    func isMatch(_ text:String, _ simplify: (String)->String) -> Bool
}

class Matchwait {
    var id:String

    init() {
        self.id = UUID().uuidString
    }
}

class MatchMessage : IMatch {
    var value:String
    var label:String
    var groups:[String]

    init(_ label:String, _ value:String) {
        self.label = label
        self.value = value
        self.groups = []
    }

    func isMatch(_ text:String, _ simplify: (String)->String) -> Bool {
        return text.range(of: simplify(value)) != nil
    }
}

class MatchreMessage : IMatch {
    var value:String
    var label:String
    var groups:[String]

    init(_ label:String, _ value:String) {
        self.label = label
        self.value = value
        self.groups = []
    }

    func isMatch(_ text:String, _ simplify: (String)->String) -> Bool {
        let val = simplify(value)
        let matches = text[val]
        self.groups = matches.firstGroup()
        return self.groups.count > 0
    }
}

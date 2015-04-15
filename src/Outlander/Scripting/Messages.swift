//
//  Messages.swift
//  Outlander
//
//  Created by Joseph McBride on 4/14/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

public class Message {
    var name:String
    
    public init(_ name:String) {
        self.name = name
    }

    public var description : String {
        return self.name;
    }
}

public class UnknownMessage : Message {
}

public class ScriptInfoMessage : Message {
    public override init(_ msg:String) {
        super.init(msg)
    }
}

public class OperationComplete : Message {
    var operation:String
    var msg:String
    
    public init(_ operation:String, msg:String) {
        self.operation = operation
        self.msg = msg
        super.init("operation-complete")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.operation)";
    }
}

public class DebugLevelMessage : Message {
    var level:ScriptLogLevel
    
    public init(_ level:Int) {
        self.level = ScriptLogLevel(rawValue: level) ?? ScriptLogLevel.None
        super.init("debug-level")
    }
}

public class PauseMessage : Message {
    var seconds:Double = 0
    
    public init(_ seconds:Double) {
        self.seconds = seconds
        super.init("pause")
    }
}

public class PutMessage : Message {
    var message:String
    
    public override init(_ message:String) {
        self.message = message
        super.init("put")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.message)";
    }
}

public class EchoMessage : Message {
    var message:String
    
    public override init(_ message:String) {
        self.message = message
        super.init("echo")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.message)";
    }
}

public class LabelMessage : Message {
    var label:String
    
    public override init(_ label:String) {
        self.label = label
        super.init("label")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label)";
    }
}

public class GotoMessage : Message {
    var label:String
    
    public override init(_ label:String) {
        self.label = label
        super.init("goto")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label)";
    }
}

public class VarMessage : Message {
    var identifier:String
    var value:String
    
    public init(_ identifier:String, _ value:String) {
        self.identifier = identifier
        self.value = value
        super.init("var")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.identifier):\(self.value)";
    }
}

public protocol IMatch {
    var value:String {get}
    var label:String {get}
    
    func isMatch(text:String) -> Bool
}

public class MatchMessage : Message, IMatch {
    public var value:String
    public var label:String
    
    public init(_ label:String, _ value:String) {
        self.label = label
        self.value = value
        super.init("match")
    }
    
    public func isMatch(text:String) -> Bool {
        return self.value == text
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label) \(self.value)";
    }
}

public class MatchReMessage : Message, IMatch {
    public var value:String
    public var label:String
    
    public init(_ label:String, _ value:String) {
        self.label = label
        self.value = value
        super.init("match")
    }
    
    public func isMatch(text:String) -> Bool {
        return false
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label) \(self.value)";
    }
}

public class MatchwaitMessage : Message {
    
    var timeout:Double?
    
    public init(_ timeout:Double?) {
        self.timeout = timeout
        super.init("matchwait")
    }
}
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
        return "\(self.operation)";
    }
}

public class CommentMessage : Message {
    public init() {
        super.init("comment")
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

public class SendMessage : Message {
    var message:String
    
    public override init(_ message:String) {
        self.message = message
        super.init("send")
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
    var params:[String]
    
    public init(_ label:String, _ params:[String]) {
        self.label = label
        self.params = params
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

public class UnVarMessage : Message {
    var identifier:String
    
    override public init(_ identifier:String) {
        self.identifier = identifier
        super.init("unvar")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.identifier)";
    }
}

public class RandomMessage : Message {
    var min:Int
    var max:Int
    
    public init(_ min:Int, _ max:Int) {
        self.min = min
        self.max = max
        super.init("random")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.min)-\(self.max)";
    }
}

public protocol IMatch {
    var value:String {get}
    var label:String {get}
    var groups:[String] {get}
    
    func isMatch(text:String) -> Bool
}

public class MatchMessage : Message, IMatch {
    public var value:String
    public var label:String
    public var groups:[String]
    
    public init(_ label:String, _ value:String) {
        self.label = label
        self.value = value
        self.groups = []
        super.init("match")
    }
    
    public func isMatch(text:String) -> Bool {
        return text.rangeOfString(value) != nil
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label) \(self.value)";
    }
}

public class MatchReMessage : Message, IMatch {
    public var value:String
    public var label:String
    public var groups:[String]
    
    public init(_ label:String, _ value:String) {
        self.label = label
        self.value = value
        self.groups = []
        super.init("match")
    }
    
    public func isMatch(text:String) -> Bool {
        self.groups = text[value].groups()
        return self.groups.count > 0
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label) \(self.value)";
    }
}

public class MatchwaitMessage : Message {
  
    var id:String
    var timeout:Double?
    
    public init(_ timeout:Double?) {
        self.id = NSUUID().UUIDString
        self.timeout = timeout
        super.init("matchwait")
    }
}

public class GosubMessage: Message {
    var label:String
    var params:[String]
    
    public init(_ label:String, _ params:[String]) {
        self.label = label
        self.params = params
        super.init("gosub")
    }
    
    public override var description : String {
        return "\(self.name) - \(self.label)";
    }
}

public class ReturnMessage : Message {
    public init() {
        super.init("return")
    }
}

public class MoveMessage : Message {
    var direction:String
    
    override public init(_ direction:String) {
        self.direction = direction
        super.init("move")
    }
}

public class NextRoomMessage : Message {
    public init() {
        super.init("nextroom")
    }
}

public class WaitforMessage : Message {
    var pattern:String
    
    override public init(_ pattern:String) {
        self.pattern = pattern
        super.init("waitfor")
    }
}

public class WaitforReMessage : Message {
    var pattern:String
    
    override public init(_ pattern:String) {
        self.pattern = pattern
        super.init("waitforre")
    }
}

public class WaitMessage : Message {
    public init() {
        super.init("wait")
    }
}

public class ShiftMessage : Message {
    public init() {
        super.init("shift")
    }
}

public class ExitMessage : Message {
    public init() {
        super.init("exit")
    }
}

public class SaveMessage : Message {
    var text:String
    
    override public init(_ text:String) {
        self.text = text
        super.init("save")
    }
}

public class WaitEvalMessage : Message {
    var token:CommandToken
    
    public init(_ token:CommandToken) {
        self.token = token
        super.init("waiteval")
    }
}

public class MathMessage : Message {
    var variable:String
    var operation:String
    var number:Double
    
    public init(_ variable:String, _ operation:String, _ number:Double) {
        self.variable = variable
        self.operation = operation
        self.number = number
        super.init("math")
    }
    
    func calcResult(start:Double) -> Double {
        
        var result:Double = 0
        
        switch operation {
        case "add":
            result = start + self.number
            
        case "subtract":
            result = start - self.number
            
        case "multiply":
            result = start * self.number
            
        case "divide":
            if self.number != 0 {
                result = start / self.number
            }
            
        case "modulus":
            result = start % self.number
            
        case "set":
            result = self.number
            
        default:
            result = start
        }
        
        return result
    }
}

public class ActionMessage : Message {
    
    var token:ActionToken
    
    public init(_ token:ActionToken) {
        self.token = token
        super.init("action")
    }
}

public class ActionInfoMessage : Message {
    
    var msg:String
    
    public override init(_ msg:String) {
        self.msg = msg
        super.init("action")
    }
}

public class EvalMessage : Message {
    
    var token:EvalCommandToken
    
    public init(_ token:EvalCommandToken) {
        self.token = token
        super.init("eval")
    }
}

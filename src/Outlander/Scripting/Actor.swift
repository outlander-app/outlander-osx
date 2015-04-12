//
//  Actor.swift
//  Scripter
//
//  Created by Joseph McBride on 11/17/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit

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

public class PauseMessage : Message {
    var seconds:Int = 0
    
    public init(_ seconds:Int) {
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

@objc
public protocol INotifyMessage {
    func notify(message:TextTag)
    func sendCommand(command:String)
}

@objc
public class NotifyMessage : INotifyMessage {
    
    class func newInstance() -> NotifyMessage {
        return NotifyMessage()
    }
    
    var messageBlock: ((message:TextTag) -> Void)?
    var commandBlock: ((command:String) -> Void)?
    
    public init() {
    }

    public func notify(message:TextTag) {
        self.messageBlock?(message: message)
    }
    
    public func sendCommand(command:String) {
        self.commandBlock?(command: command)
    }
}

public protocol IAcceptMessage {
    func sendMessage(msg:Message);
}

public protocol IScript : IAcceptMessage, INotifyMessage {
}

public protocol Actor {
    func addOperation(op:NSOperation);
}

public class Thread : Actor {
    lazy var queue:NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Script queue"
//        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    var notifier:INotifyMessage?
    
    public init(_ notifier:INotifyMessage) {
        self.notifier = notifier
    }
    
    public func addOperation(op:NSOperation) {
        queue.addOperation(op);
    }
}

public class BaseOp : NSOperation {
    
    var _paused = false
    
    public var uuid = NSUUID()
    
    public func pause() {
        self._paused = true
    }
    
    public func resume() {
        self._paused = false
    }
}

public class Script : BaseOp, IScript {
  
    var scriptName:String
    var notifier:INotifyMessage
    var actor:Actor
    var context:ScriptContext?
    var started:NSDate?
    
    private var nextAfterUnpause = false
    
    let tokenToMessage = TokenToMessage()
    var currentLine:Int?
    var currentIndex:Int?
    
    public init(_ scriptName:String, _ notifier:INotifyMessage, _ actor:Actor) {
        self.scriptName = scriptName
        self.notifier = notifier
        self.actor = actor
    }
    
    public override func main () {
        autoreleasepool {
            
            self.started = NSDate()
            
            self.sendMessage(ScriptInfoMessage("Starting \(self.scriptName)\n"))
            
            while !self.cancelled {
            }
            
            let diff = NSDate().timeIntervalSinceDate(self.started!)
            
            self.sendMessage(ScriptInfoMessage("Script Completed - \(diff) seconds\n"))
        }
    }
    
    override public func resume() {
        super.resume()
        
        if nextAfterUnpause {
            nextAfterUnpause = false
            self.moveNext()
        }
    }
    
    public func vars() {
    }
    
    public func run(script:String, globalVars:(()->[String:String])?, params:[String]) {
        let parser = OutlanderScriptParser()
        let tokens = parser.parseString(script)
        
        self.context = ScriptContext(tokens, globalVars: globalVars, params: params)
        self.moveNext()
    }
    
    public func moveNext() {
        
        if self.cancelled {
            return
        }
        
        if self._paused {
            self.nextAfterUnpause = true
            return
        }
        
        var result = self.context!.next()
        if let nextToken = result {
            
            self.currentLine = nextToken.originalStringLine
            self.currentIndex = nextToken.originalStringIndex
            
            println("next - \(nextToken.description)")
            
            if let msg = tokenToMessage.toMessage(self.context!, token: nextToken) {
                self.sendMessage(msg)
            } else {
                println("canceling with no message")
                // end of script
                self.cancel()
            }
        } else {
            println("canceling from iteration")
            // end of script
            self.cancel()
        }
    }
    
    public func sendMessage(msg:Message) {
        
        if self.cancelled && !(msg is ScriptInfoMessage) {
            return
        }
        
        if let opComplete = msg as? OperationComplete {
            self.notify(TextTag(with: "\(opComplete.description) - \(opComplete.msg)\n", mono: true))
            self.moveNext()
        }
        else if let pauseMsg = msg as? PauseMessage {
            self.actor.addOperation(PauseOp(self, seconds:pauseMsg.seconds))
        }
        else if let putMsg = msg as? PutMessage {
            self.sendCommand(putMsg.message)
            self.moveNext()
        }
        else if let labelMsg = msg as? LabelMessage {
            self.notify(TextTag(with: "Passing Label: \(labelMsg.label)\n", mono: true))
            self.moveNext()
        }
        else if let gotoMsg = msg as? GotoMessage {
            self.notify(TextTag(with: "Goto label: \(gotoMsg.label)\n", mono: true))
            self.context?.gotoLabel(gotoMsg.label)
            self.moveNext()
        }
        else if let varMsg = msg as? VarMessage {
            self.context?.setVariable(varMsg.identifier, value: varMsg.value)
            self.notify(TextTag(with: "setvariable \(varMsg.identifier) \(varMsg.value)\n", mono: true))
            self.moveNext()
        }
        else if let unkownMsg = msg as? UnknownMessage {
            let txtMsg = TextTag(with: "Unkown Command: \(unkownMsg.description)\n", mono: true)
            txtMsg.color = "#efefef"
            txtMsg.backgroundColor = "#ff3300"
            self.notify(txtMsg)
            self.moveNext()
        }
        else if let scriptInfo = msg as? ScriptInfoMessage {
            let txtMsg = TextTag(with: scriptInfo.description, mono: true)
            self.notify(txtMsg)
        }
        else {
            self.notify(TextTag(with: "\(msg.description)\n", mono: true))
            self.moveNext()
        }
    }
    
    public func notify(message: TextTag) {
        message.scriptName = self.scriptName
        
        var line = self.currentLine != nil ? Int32(self.currentLine!) : -1
        message.scriptLine = line
        //message.scriptIndex = self.currentIndex
        self.notifier.notify(message)
    }
    
    public func sendCommand(command: String) {
        self.notifier.sendCommand(command)
    }
}

public class TokenToMessage {
    
    public func toMessage(context:ScriptContext, token:Token) -> Message? {
        
        var msg:Message? = UnknownMessage(token.description)
        
        if let branch = token as? BranchToken {
            
            msg = OperationComplete("branch", msg: branch.lastResult ?? "")
            
        }
        else if let label = token as? LabelToken {
            
            msg = LabelMessage(label.characters)
            
        }
        else if let cmd = token as? CommandToken {
            switch cmd.name {
            case "goto":
                msg = GotoMessage(context.simplifyEach(cmd.body))
                
            case "put":
                msg = PutMessage(context.simplifyEach(cmd.body))
                
            case "pause":
                var lengthStr = cmd.bodyText().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                msg = PauseMessage(lengthStr.toInt()!)
                
            case "var", "setvariable":
                
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var identifier = txt.removeAtIndex(0)
                var value = " ".join(txt)
                
                msg = VarMessage(identifier, value)
                
            default:
                msg = UnknownMessage(token.description)
            }
        }
        
        return msg
    }
}

public class PauseOp : BaseOp {
    
    var actor:IScript
    var seconds:Int
    
    init(_ actor:IScript, seconds:Int) {
        self.actor = actor
        self.seconds = seconds
    }
    
    public override func main () {
        autoreleasepool() {
            var text = "pausing for \(self.seconds) seconds\n"
            var txtMsg = TextTag(with: text, mono: true)
            //txtMsg.color = "#efefef"
            txtMsg.backgroundColor = "#ff3300"
            self.actor.notify(txtMsg)
            
            sleep(UInt32(self.seconds))
            
            self.actor.sendMessage(OperationComplete("pause", msg: ""))
        }
    }
}

extension String {
    
    func toDouble() -> Double? {
        enum F {
            static let formatter = NSNumberFormatter()
        }
        if let number = F.formatter.numberFromString(self) {
            return number.doubleValue
        }
        return nil
    }
    
    func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    
    func indexOfCharacter(char: Character) -> Int? {
        if let idx = find(self, char) {
            return distance(self.startIndex, idx)
        }
        return nil
    }
}

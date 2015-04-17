//
//  Actor.swift
//  Scripter
//
//  Created by Joseph McBride on 11/17/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit

@objc
public protocol INotifyMessage {
    func notify(message:TextTag)
    func sendCommand(command:CommandContext)
    func sendEcho(echo:String)
}

@objc
public class NotifyMessage : INotifyMessage {
    
    class func newInstance() -> NotifyMessage {
        return NotifyMessage()
    }
    
    var messageBlock: ((message:TextTag) -> Void)?
    var commandBlock: ((command:CommandContext) -> Void)?
    var echoBlock: ((echo:String) -> Void)?
    
    public init() {
    }

    public func notify(message:TextTag) {
        self.messageBlock?(message: message)
    }
    
    public func sendCommand(command:CommandContext) {
        self.commandBlock?(command: command)
    }
    
    public func sendEcho(echo:String) {
        self.echoBlock?(echo: echo)
    }
}

public protocol IAcceptMessage {
    func sendMessage(msg:Message);
}

public protocol IScript : IAcceptMessage {
    var scriptName:String { get }
   
    func cancel()
    func pause()
    func resume()
    func vars()
    func notify(message: TextTag)
    func stream(text:String, nodes:[Node])
    func moveNext()
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

public enum ScriptLogLevel : Int {
    case None = 0
    case Method = 5
}

public class Script : BaseOp, IScript {
  
    public var scriptName:String
    var notifier:INotifyMessage
    var actor:Actor
    var context:ScriptContext?
    var started:NSDate?
    var logLevel = ScriptLogLevel.None
    
    private var nextAfterUnpause = false
    private var nextAfterRoundtime = false
    private var matchStack:[IMatch]
    private var matchwait:MatchwaitMessage?
    
    private var reactToStream:[IWantStreamInfo]
    
    let tokenToMessage = TokenToMessage()
    var currentLine:Int?
    var currentColumn:Int?
    
    public init(_ scriptName:String, _ notifier:INotifyMessage, _ actor:Actor) {
        self.scriptName = scriptName
        self.notifier = notifier
        self.actor = actor
        self.matchStack = []
        self.reactToStream = []
    }
    
    public override func main () {
        autoreleasepool {
            
            self.started = NSDate()
            
            self.sendMessage(ScriptInfoMessage("Starting \(self.scriptName)\n"))
            
            while !self.cancelled {
            }
            
            self.currentLine = nil
            self.currentColumn = nil
            
            let diff = NSDate().timeIntervalSinceDate(self.started!)
            
            self.sendMessage(ScriptInfoMessage(String(format: "Script \(self.scriptName) completed - %.02f seconds total run time\n", diff)))
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
    
    public func stream(text:String, nodes:[Node]) {
        
        if self.nextAfterRoundtime {
            self.doNextAfterRoundtime(nodes)
        }
        
        self.matches(text)
        
        var handlers = self.reactToStream.filter { x in
            var res = x.stream(text, nodes: nodes)
            switch res {
            case .Match(let x):
                return true
            default:
                return false
            }
        }
        
        handlers.forEach { handler in
            var idx = self.reactToStream.find { $0.id == handler.id  }
            self.reactToStream.removeAtIndex(idx!)
            handler.execute(self)
        }
    }
    
    private func addStreamWatcher(watcher:IWantStreamInfo) {
        self.reactToStream.append(watcher)
    }
    
    private func matches(text:String) {
        if let wait = self.matchwait {
            for match in self.matchStack {
                if match.isMatch(text) {
                    var label = self.context!.simplify(match.label)
                    self.notify(TextTag(with: "match \(label)\n", mono: true))
                    self.gotoLabel(label, params:match.groups, previousLine:-1)
                    
                    self.matchStack.removeAll()
                    self.matchwait = nil
                    
                    self.moveNext()
                }
            }
        }
    }
    
    private func gotoLabel(label:String, params:[String], previousLine:Int, isGosub:Bool = false) {
        if !self.context!.gotoLabel(label, params: params, previousLine:previousLine, isGosub: isGosub) {
            
            var tag = TextTag(with: "label \(label) not found\n", mono: true)
            
            tag.color = "#efefef"
            tag.backgroundColor = "#ff3300"
            
            self.notify(tag)
        }
    }
    
    private func gosubReturn() {
        if let ctx = self.context!.popGosub() {
            var tag = TextTag(with: "returning to line \(ctx.returnLine + 1)\n", mono: true)
            self.notify(tag)
            self.moveNext()
        } else {
            var tag = TextTag(with: "no gosub to return to!\n", mono: true)
            
            tag.color = "#efefef"
            tag.backgroundColor = "#ff3300"
            
            self.notify(tag)
            self.cancel()
        }
    }
    
    private func doNextAfterRoundtime(nodes:[Node]) {
        for node in nodes {
            if node.name == "prompt" {
                self.nextAfterRoundtime = false
                if let roundtime = self.context!.roundtime() {
                    if roundtime > 0 {
                        after(roundtime) {
                            self.moveNext()
                        }
                        return
                    }
                }
                
                self.moveNext()
            }
        }
    }
    
    public func run(script:String, globalVars:(()->[String:String])?, params:[String]) {
        let parser = OutlanderScriptParser()
        let tokens = parser.parseString(script)
        
        self.context = ScriptContext(tokens, globalVars: globalVars, params: params)
        self.context!.marker.currentIdx = -1
        self.moveNext()
    }
    
    public func moveNextAfterRoundtime() {
        
        if let roundtime = self.context!.roundtime() {
            if roundtime > 0 {
                after(roundtime) {
                    self.moveNext()
                }
                return
            }
        }
        
        self.nextAfterRoundtime = true
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
            if opComplete.operation == "pause" {
                self.moveNextAfterRoundtime()
            }
            else {
                self.moveNext()
            }
        }
        else if let match = msg as? IMatch {
            self.matchStack.append(match)
            self.moveNext()
        }
        else if let matchwait = msg as? MatchwaitMessage {
            self.notify(TextTag(with: "matchwait\n", mono: true))
            self.matchwait = matchwait
        }
        else if let pauseMsg = msg as? PauseMessage {
            self.actor.addOperation(PauseOp(self, seconds: pauseMsg.seconds))
        }
        else if let debugMsg = msg as? DebugLevelMessage {
            self.logLevel = debugMsg.level
            self.notify(TextTag(with: "debuglevel \(debugMsg.level.rawValue)\n", mono: true))
            self.moveNext()
        }
        else if let putMsg = msg as? PutMessage {
            
            self.notify(TextTag(with: "put \(putMsg.message)\n", mono: true))
            self.sendCommand(putMsg.message)
            self.moveNext()
        }
        else if let echoMsg = msg as? EchoMessage {
            
            self.notify(TextTag(with: "echo \(echoMsg.message)\n", mono: true))
            self.sendEcho(echoMsg.message)
            
            self.moveNext()
        }
        else if let labelMsg = msg as? LabelMessage {
            self.notify(TextTag(with: "passing label \(labelMsg.label)\n", mono: true))
            self.moveNext()
        }
        else if let gotoMsg = msg as? GotoMessage {
            var params = gotoMsg.params.count > 0 ? gotoMsg.params[0] : ""
            self.notify(TextTag(with: "goto \(gotoMsg.label) \(params)\n", mono: true))
            self.gotoLabel(gotoMsg.label, params:gotoMsg.params, previousLine: self.currentLine!)
            self.moveNext()
        }
        else if let gosubMsg = msg as? GosubMessage {
            var params = gosubMsg.params.count > 0 ? gosubMsg.params[0] : ""
            self.notify(TextTag(with: "gosub \(gosubMsg.label) \(params)\n", mono: true))
            self.gotoLabel(gosubMsg.label, params:gosubMsg.params, previousLine: self.currentLine!, isGosub:true)
            self.moveNext()
        }
        else if let returnMsg = msg as? ReturnMessage {
            self.gosubReturn()
        }
        else if let varMsg = msg as? VarMessage {
            var res = self.context!.simplify(varMsg.value)
            self.context?.setVariable(varMsg.identifier, value: res)
            self.notify(TextTag(with: "setvariable \(varMsg.identifier) \(res)\n", mono: true))
            self.moveNext()
        }
        else if let waitForMsg = msg as? WaitforMessage {
            self.notify(TextTag(with: "waitfor \(waitForMsg.pattern)\n", mono: true))
            self.addStreamWatcher( WaitforOp(waitForMsg.pattern) )
        }
        else if let waitForMsg = msg as? WaitforReMessage {
            self.notify(TextTag(with: "waitforre \(waitForMsg.pattern)\n", mono: true))
            self.addStreamWatcher( WaitforReOp(waitForMsg.pattern) )
        }
        else if let moveMsg = msg as? MoveMessage {
            self.addStreamWatcher( MoveOp() )
            
            self.notify(TextTag(with: "move \(moveMsg.direction)\n", mono: true))
            self.sendCommand(moveMsg.direction)
        }
        else if let moveMsg = msg as? NextRoomMessage {
            self.addStreamWatcher( NextRoomOp() )
            self.notify(TextTag(with: "nextroom\n", mono: true))
        }
        else if let shiftMsg = msg as? ShiftMessage {
            var res = self.context!.shiftParamVars()
            if res {
                self.notify(TextTag(with: "shift\n", mono: true))
                self.moveNext()
            } else {
                let txtMsg = TextTag(with: "no more params to shift!\n", mono: true)
                txtMsg.color = "#efefef"
                txtMsg.backgroundColor = "#ff3300"
                self.notify(txtMsg)
                self.cancel()
            }
        }
        else if let unkownMsg = msg as? UnknownMessage {
            let txtMsg = TextTag(with: "unkown command: \(unkownMsg.description)\n", mono: true)
            txtMsg.color = "#efefef"
            txtMsg.backgroundColor = "#ff3300"
            self.notify(txtMsg)
            self.moveNext()
        }
        else if let scriptInfo = msg as? ScriptInfoMessage {
            let txtMsg = TextTag(with: scriptInfo.description, mono: true)
            txtMsg.color = "#acff2f"
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
        
        if message.color == nil {
            message.color = "#0066cc"
        }
        
        self.notifier.notify(message)
    }
    
    public func sendEcho(echo:String) {
        self.notifier.sendEcho("\(echo)\n")
    }
    
    public func sendCommand(command: String) {
        
        var ctx = CommandContext()
        ctx.command = command
        
        var line = self.currentLine != nil ? Int32(self.currentLine!) : -1
        ctx.scriptName = self.scriptName
        ctx.scriptLine = line
        
        self.notifier.sendCommand(ctx)
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
                
            case "echo":
                msg = EchoMessage(
                    context
                        .simplifyEach(cmd.body)
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                )
                
            case "goto":
                var args = context.simplifyEach(cmd.body)
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    .componentsSeparatedByString(" ")
                
                var label = args.removeAtIndex(0)
                var allArgs = " ".join(args)
                args.insert(allArgs, atIndex: 0)
                
                msg = GotoMessage(label, args)
                
            case "put":
                msg = PutMessage(
                    context
                        .simplifyEach(cmd.body)
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                )
                
            case "pause":
                var lengthStr = cmd.bodyText()
                msg = PauseMessage(lengthStr.toDouble() ?? 1)
                
            case "debuglevel":
                var levelStr = cmd.bodyText()
                msg = DebugLevelMessage(levelStr.toInt()!)
                
            case "var", "setvariable":
                
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var identifier = txt.removeAtIndex(0)
                var value = " ".join(txt)
                
                msg = VarMessage(identifier, value)

            case "matchwait":
                var timeoutStr = cmd.bodyText()
                msg = MatchwaitMessage(timeoutStr.toDouble())

            case "matchre":
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var label = txt.removeAtIndex(0)
                var value = " ".join(txt)
                msg = MatchReMessage(label, value)
                
            case "match":
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var label = txt.removeAtIndex(0)
                var value = " ".join(txt)
                
                msg = MatchMessage(label, value)
                
            case "waitforre":
                msg = WaitforReMessage(cmd.bodyText())
                
            case "waitfor":
                msg = WaitforMessage(cmd.bodyText())
                
            case "gosub":
                var args = context.simplifyEach(cmd.body)
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    .componentsSeparatedByString(" ")
                
                var label = args.removeAtIndex(0)
                var allArgs = " ".join(args)
                args.insert(allArgs, atIndex: 0)
                
                msg = GosubMessage(label, args)
            
            case "return":
                msg = ReturnMessage()
                
            case "nextroom":
                msg = NextRoomMessage()
                
            case "move":
                var direction = context.simplifyEach(cmd.body)
                msg = MoveMessage(direction.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                
            case "shift":
                msg = ShiftMessage()
                
            default:
                msg = UnknownMessage(token.description)
            }
        }
        
        return msg
    }
}

public class PauseOp : BaseOp {
    
    var actor:IScript
    var seconds:Double
    
    init(_ actor:IScript, seconds:Double) {
        self.actor = actor
        self.seconds = seconds
    }
    
    public override func main () {
        autoreleasepool() {
            var text = String(format: "pausing for %.02f seconds\n", self.seconds)
            var txtMsg = TextTag(with: text, mono: true)
            txtMsg.color = "#efefef"
            txtMsg.backgroundColor = "#ff3300"
            self.actor.notify(txtMsg)
            
            after(self.seconds) {
                self.actor.sendMessage(OperationComplete("pause", msg: ""))
            }
        }
    }
}

private func after(seconds:Double, complete:()->Void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))),
        dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)) {
            
        complete()
    }
}

public protocol IWantStreamInfo {
    
    var id:String {get set}
    
    func stream(text:String, nodes:[Node]) -> CheckStreamResult
    func execute(script:IScript)
}

public class MoveOp : IWantStreamInfo {
    
    public var id = ""
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        for node in nodes {
            
            if node.name == "compass" {
                return CheckStreamResult.Match(result: "")
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript) {
        script.moveNext()
    }
}

public class NextRoomOp : IWantStreamInfo {
    
    public var id = ""
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        
        for node in nodes {
            
            if node.name == "compass" {
                return CheckStreamResult.Match(result: "")
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript) {
        script.moveNext()
    }
}

public class WaitforOp : IWantStreamInfo {
    
    public var id = ""
    var target:String
    
    public init(_ target:String) {
        self.id = NSUUID().UUIDString
        self.target = target
    }
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        return text.rangeOfString(self.target) != nil ? CheckStreamResult.Match(result: text) : CheckStreamResult.None
    }
    
    public func execute(script:IScript) {
        script.moveNext()
    }
}

public class WaitforReOp : IWantStreamInfo {

    public var id = ""
    var pattern:String
    
    public init(_ pattern:String) {
        self.id = NSUUID().UUIDString
        self.pattern = pattern
    }
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        var groups = text[self.pattern].groups()
        return groups.count > 0 ? CheckStreamResult.Match(result: text) : CheckStreamResult.None
    }
    
    public func execute(script:IScript) {
        script.moveNext()
    }
}

public enum CheckStreamResult {
    case None
    case Match(result:String)
}

extension Array {
    func forEach(doThis: (element: T) -> Void) {
        for e in self {
            doThis(element: e)
        }
    }
    
    func find(includedElement: T -> Bool) -> Int? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        return nil
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

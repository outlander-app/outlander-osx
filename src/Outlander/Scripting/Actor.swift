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
public class NotifyMessage : NSObject, INotifyMessage {
    
    class func newInstance() -> NotifyMessage {
        return NotifyMessage()
    }
    
    var messageBlock: ((message:TextTag) -> Void)?
    var commandBlock: ((command:CommandContext) -> Void)?
    var echoBlock: ((echo:String) -> Void)?
    
    public override init() {
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
    func sendActionMessage(msg:Message)
}

public protocol IScript : IAcceptMessage {
    var scriptName:String { get }
    var logLevel:ScriptLogLevel { get }
    
    var completed:((String, String?)->Void)? {get set}
    
    func run(script:String, globalVars:(()->[String:String])?, params:[String])
  
    func printInfo()
    func cancel()
    func pause()
    func resume()
    func vars()
    func setLogLevel(level:ScriptLogLevel)
    func notify(message: TextTag, debug:ScriptLogLevel)
    func stream(text:String, nodes:[Node])
    func varsChanged(vars:[String:String])
    func moveNext()
    func moveNextAfterRoundtime()
}

public enum ScriptLogLevel : Int {
    case None = 0
    case Gosubs = 1
    case Wait = 2
    case If = 3
    case Vars = 4
    case Actions = 5
}

public class Script : IScript {
  
    public var scriptName:String
    public var logLevel = ScriptLogLevel.None
    
    var notifier:INotifyMessage
    var context:ScriptContext?
    var started:NSDate?
    
    public var cancelled = false
    public var paused = false
    public var completed:((String, String?)->Void)?

    private var nextAfterUnpause = false
    private var matchStack:[IMatch]
    private var matchwait:MatchwaitMessage?
    
    private var actions:[IAction]
    private var reactToStream:[IWantStreamInfo]
    
    let tokenToMessage = TokenToMessage()
    var currentLine:Int?
    var currentColumn:Int?
    
    public init(_ scriptName:String, _ notifier:INotifyMessage) {
        self.scriptName = scriptName
        self.notifier = notifier
        self.matchStack = []
        self.actions = []
        self.reactToStream = []
    }
    
    public func printInfo() {
        let diff = NSDate().timeIntervalSinceDate(self.started!)
        self.sendMessage(ScriptInfoMessage(String(format: "[Script '\(self.scriptName)' running for %.02f seconds]\n", diff)))
    }
    
    public func cancel() {
        
        self.cancelled = true
        
        self.matchwait = nil
        self.matchStack.removeAll(keepCapacity: false)
        self.actions.removeAll(keepCapacity: false)
        self.reactToStream.removeAll(keepCapacity: false)
        
        self.currentLine = nil
        self.currentColumn = nil
        
        let diff = NSDate().timeIntervalSinceDate(self.started!)
        
        self.sendMessage(ScriptInfoMessage(String(format: "[Script '\(self.scriptName)' completed after %.02f seconds total run time]\n", diff)))
    }
    
    public func pause() {
       
        self.paused = true
        
        let line = self.currentLine
        let column = self.currentColumn
        
        self.currentLine = nil
        self.currentColumn = nil
        
        self.sendMessage(ScriptInfoMessage("[Pausing '\(self.scriptName)']\n"))
        
        self.currentLine = line
        self.currentColumn = column
    }
    
    public func resume() {
        
        if !self.paused {
            return
        }
        
        let line = self.currentLine
        let column = self.currentColumn
        
        self.currentLine = nil
        self.currentColumn = nil
        
        self.sendMessage(ScriptInfoMessage("[Resuming '\(self.scriptName)']\n"))
        
        self.currentLine = line
        self.currentColumn = column
       
        self.paused = false
        
        if nextAfterUnpause {
            nextAfterUnpause = false
            self.moveNext()
        }
    }
    
    public func vars() {
        if let display = self.context?.varsForDisplay() {
            
            let diff = NSDate().timeIntervalSinceDate(self.started!)
            self.notify(
                TextTag(
                    preset: String(format:"+----- '\(self.scriptName)' variables (running for %.02f seconds) -----+\n", diff),
                    mono: true,
                    preset: "scriptinfo"))
            
            let sorted = display.sort { $0 < $1 }
            
            for v in sorted {
                let tag = TextTag(preset: "|  \(v)\n", mono: true, preset: "scriptinfo")
                self.notify(tag)
            }
            
            self.notify(TextTag(preset: "+---------------------------------------------------------+\n", mono: true, preset: "scriptinfo"))
        }
    }
    
    public func setLogLevel(level:ScriptLogLevel) {
        self.logLevel = level
        self.sendMessage(ScriptInfoMessage("[Script '\(self.scriptName)' - setting debug level to \(level.rawValue)]\n"))
    }
    
    public func varsChanged(vars:[String:String]) {
        let actions = self.actions.filter { x in
            
            if !x.enabled {
                return false
            }
            
            let res = x.vars(self.context!, vars: vars)
            switch res {
            case .Match(let x, _):
                self.notify(TextTag(x, mono: true), debug:ScriptLogLevel.Actions)
                return true
            default:
                return false
            }
        }
        
        actions.forEach { action in
            action.execute(self, context: self.context!)
        }
    }
    
    public func stream(text:String, nodes:[Node]) {
        
        if (text.characters.count == 0 && nodes.count == 0) || self.paused || self.cancelled {
            return
        }
        
        self.matches(text)
        
        let handlers = self.reactToStream.filter { x in
            let res = x.stream(text, nodes: nodes, context: self.context!)
            switch res {
            case .Match:
                return true
            default:
                return false
            }
        }
        
        handlers.forEach { handler in
            let idx = self.reactToStream.find { $0.id == handler.id  }
            self.reactToStream.removeAtIndex(idx!)
            handler.execute(self, context: self.context!)
        }
        
        let actions = self.actions.filter { x in
            
            if !x.enabled {
                return false
            }
            
            let res = x.stream(text, nodes: nodes, context: self.context!)
            switch res {
            case .Match(let x, _):
                self.notify(TextTag(x, mono: true), debug:ScriptLogLevel.Actions)
                return true
            default:
                return false
            }
        }
        
        actions.forEach { action in
            action.execute(self, context: self.context!)
        }
    }
    
    private func addStreamWatcher(watcher:IWantStreamInfo) {
        self.reactToStream.append(watcher)
    }
    
    private func matches(text:String) {
        if let _ = self.matchwait {
            
            var matched = false
            
            for match in self.matchStack {
                if match.isMatch(text, self.context!.simplify) {
                    let label = self.context!.simplify(match.label)
                    self.notify(TextTag("match \(label)\n", mono: true), debug:ScriptLogLevel.Wait)
                    
                    if label.lowercaseString == "return" {
                        self.gosubReturn(false)
                    } else {
                        self.gotoLabel(label, params:match.groups, previousLine:-1, isGosub:false)
                    }
                    
                    self.matchStack.removeAll(keepCapacity: true)
                    self.matchwait = nil
                    
                    matched = true
                    break
                }
            }
            
            if matched {
                self.moveNextAfterRoundtime()
            }
        }
    }
    
    private func gotoLabel(label:String, params:[String], previousLine:Int, isGosub:Bool = false) {
        if !self.context!.gotoLabel(label, params: params, previousLine:previousLine, isGosub: isGosub) {
            
            let tag = TextTag("label \(label) not found\n", mono: true)
            tag.preset = "scripterror"
            
            self.notify(tag)
        }
        
        if self.context!.gosubStack.count() >= 100 {
            let tag = TextTag("Potential infinite loop of 100+ gosubs - use gosub clear if this is intended\n", mono: true)
            tag.preset = "scripterror"
            
            self.notify(tag)
            
            self.cancel()
            self.completed?(self.scriptName, "100+ gosubs")
        }
    }
    
    private func gosubReturn(moveNext:Bool) {
        guard let ctx = self.context!.popGosub() else {

            let tag = TextTag("no gosub to return to!\n", mono: true)
            
            tag.preset = "scripterror"
            
            self.notify(tag)
            self.cancel()
            self.completed?(self.scriptName, "no gosub to return to")
            return
        }

        let tag = TextTag("returning to line \(ctx.returnLine + 1)\n", mono: true)
        self.notify(tag, debug: ScriptLogLevel.Gosubs)
        if moveNext {
            self.moveNext()
        }
    }
    
    public func run(script:String, globalVars:(()->[String:String])?, params:[String]) {
        
        self.started = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedDate = dateFormatter.stringFromDate(self.started!)
        
        self.sendMessage(ScriptInfoMessage("[Starting '\(self.scriptName)' at \(formattedDate)]\n"))
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let parser = OutlanderScriptParser()
            let tokens = parser.parseString(script)
            
            let parseTime = NSDate().timeIntervalSinceDate(self.started!)
            
            print("parsed \(self.scriptName) in \(parseTime)")
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if parser.errors.count > 0 {
                    
                    for err in parser.errors {
                        let tag = TextTag("\(err)\n", mono: true)
                        tag.preset = "scripterror"
                        self.notify(tag)
                    }
                    self.cancel()
                    self.completed?(self.scriptName, nil)
                    return
                }
                
                self.context = ScriptContext(tokens, globalVars: globalVars, params: params)
                self.context!.marker.currentIdx = -1
                self.context!.setVariable("scriptname", value: self.scriptName)
                self.moveNext()
            })
        })
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
        
        self.moveNext()
    }
    
    public func moveNext() {
        
        if self.cancelled {
            return
        }
        
        if self.paused {
            self.nextAfterUnpause = true
            return
        }
        
        let result = self.context!.next()
        if let nextToken = result {
            
            self.currentLine = nextToken.originalStringLine
            
            print("next - \(nextToken.description)")
            
            if let msg = tokenToMessage.toMessage(self.context!, token: nextToken) {
                self.sendMessage(msg)
            } else {
                // end of script
                self.cancel()
                self.completed?(self.scriptName, "completed with no message")
            }
        } else {
            // end of script
            self.cancel()
            self.completed?(self.scriptName, "completed from iteration")
        }
    }
    
    public func sendActionMessage(msg:Message) {
        
        if msg is GotoMessage {
            self.reactToStream = []
            self.matchwait = nil
            self.matchStack = []
            self.handleGoto(msg as! GotoMessage)
        }
            
        else if msg is PutMessage {
            self.handlePut(msg as! PutMessage)
        }
        
        else if msg is VarMessage {
            self.handleVar(msg as! VarMessage)
        }
        
        else if msg is SendMessage {
            self.handleSend(msg as! SendMessage)
        }
        
        else if msg is EchoMessage {
            self.handleEcho(msg as! EchoMessage)
        }
        
        else if msg is SaveMessage {
            self.handleSave(msg as! SaveMessage)
        }
            
        else if msg is MathMessage {
            self.handleMath(msg as! MathMessage)
        }
        
        else if msg is RandomMessage {
            self.handleRandom(msg as! RandomMessage)
        }
        
        else if msg is UnVarMessage {
            self.handleUnVar(msg as! UnVarMessage)
        }
    }
    
    public func sendMessage(msg:Message) {
        
        if self.cancelled && !(msg is ScriptInfoMessage) {
            return
        }
        
        if let opComplete = msg as? OperationComplete {
            if opComplete.operation == "if" || opComplete.operation == "elseif" {
                self.notify(TextTag("\(opComplete.description) - \(opComplete.msg)\n", mono: true), debug:ScriptLogLevel.If)
            }
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
            let timeStr = matchwait.timeout != nil ? "\(matchwait.timeout!)" : ""
            self.notify(TextTag("matchwait \(timeStr)\n", mono: true), debug:ScriptLogLevel.Wait)
            
            self.matchwait = matchwait
           
            if let timeout = matchwait.timeout {
                after(timeout) {
                    if let match = self.matchwait where match.id == matchwait.id {
                        self.matchwait = nil
                        self.matchStack.removeAll(keepCapacity: true)
                        self.notify(TextTag("matchwait timeout\n", mono: true), debug:ScriptLogLevel.Wait)
                        self.moveNextAfterRoundtime()
                    }
                }
            }
        }
        else if let pauseMsg = msg as? PauseMessage {
            let op = PauseOp(self, seconds: pauseMsg.seconds)
            op.run()
        }
        else if let debugMsg = msg as? DebugLevelMessage {
            self.logLevel = debugMsg.level
            self.notify(TextTag("debuglevel \(debugMsg.level.rawValue)\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.moveNext()
        }
        else if let putMsg = msg as? PutMessage {
            
            self.handlePut(putMsg)
            self.moveNext()
        }
        else if let sendMsg = msg as? SendMessage {
            self.handleSend(sendMsg)
            self.moveNext()
        }
        else if let echoMsg = msg as? EchoMessage {
            
            self.handleEcho(echoMsg)
            self.moveNext()
        }
        else if let labelMsg = msg as? LabelMessage {
            self.notify(TextTag("passing label \(labelMsg.label)\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.moveNext()
        }
        else if let gotoMsg = msg as? GotoMessage {
            self.handleGoto(gotoMsg)
        }
        else if let gosubMsg = msg as? GosubMessage {
            let params = gosubMsg.params.count > 0 ? gosubMsg.params[0] : ""
            self.notify(TextTag("gosub \(gosubMsg.label) \(params)\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.gotoLabel(gosubMsg.label, params:gosubMsg.params, previousLine: self.currentLine!, isGosub:true)
            self.moveNext()
        }
        else if let _ = msg as? ReturnMessage {
            self.gosubReturn(true)
        }
        else if let varMsg = msg as? VarMessage {
            self.handleVar(varMsg)
            self.moveNext()
        }
        else if let waitForMsg = msg as? WaitforMessage {
            self.notify(TextTag("waitfor \(context!.simplify(waitForMsg.pattern))\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitforOp(waitForMsg.pattern) )
        }
        else if let waitForMsg = msg as? WaitforReMessage {
            self.notify(TextTag("waitforre \(context!.simplify(waitForMsg.pattern))\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitforReOp(waitForMsg.pattern) )
        }
        else if let _ = msg as? WaitMessage {
            self.notify(TextTag("wait\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitforPromptOp() )
        }
        else if let waitEvalMsg = msg as? WaitEvalMessage {
            self.notify(TextTag("waiteval \(waitEvalMsg.token.bodyText())\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitEvalOp(waitEvalMsg.token) )
        }
        else if let saveMsg = msg as? SaveMessage {
            self.handleSave(saveMsg)
            self.moveNext()
        }
        else if let unVarMsg = msg as? UnVarMessage {
            self.handleUnVar(unVarMsg)
            self.moveNext()
        }
        else if let moveMsg = msg as? MoveMessage {
            self.addStreamWatcher( MoveOp() )
            
            self.notify(TextTag("move \(moveMsg.direction)\n", mono: true), debug:ScriptLogLevel.Wait)
            self.sendCommand(moveMsg.direction)
        }
        else if let _ = msg as? NextRoomMessage {
            self.addStreamWatcher( NextRoomOp() )
            self.notify(TextTag("nextroom\n", mono: true), debug:ScriptLogLevel.Wait)
        }
        else if let _ = msg as? ShiftMessage {
            let res = self.context!.shiftParamVars()
            if res {
                self.notify(TextTag("shift\n", mono: true), debug:ScriptLogLevel.Vars)
                self.moveNext()
            } else {
                let txtMsg = TextTag("no more params to shift!\n", mono: true)
                txtMsg.preset = "scripterror"
                
                self.notify(txtMsg)
                self.cancel()
                self.completed?(self.scriptName, "no more params to shift")
            }
        }
        else if let randomMsg = msg as? RandomMessage {
            self.handleRandom(randomMsg)
            self.moveNext()
        }
        else if let mathMsg = msg as? MathMessage {
           
            self.handleMath(mathMsg)
            self.moveNext()
        }
        else if let evalMsg = msg as? EvalMessage {
            self.handleEval(evalMsg)
            self.moveNext()
        }
        else if let actionMsg = msg as? ActionMessage {
            
            if let _ = actionMsg.token.actionToggle {
                self.toggleAction(actionMsg)
                self.notify(TextTag("action (\(actionMsg.token.className)) \(actionMsg.token.commandText())\n", mono: true), debug:ScriptLogLevel.Actions)
            } else {
                let whenText = self.context!.simplify(actionMsg.token.whenText)
                self.notify(TextTag("action \(actionMsg.token.commandText()) when \(whenText)\n", mono: true), debug:ScriptLogLevel.Actions)
                self.actions.append(ActionOp(actionMsg.token, self.context!.simplify))
            }
            
            self.moveNext()
        }
        else if let actionInfoMsg = msg as? ActionInfoMessage {
            self.notify(TextTag("action - \(actionInfoMsg.msg)\n", mono: true), debug:ScriptLogLevel.Actions)
        }
        else if let _ = msg as? CommentMessage {
            self.moveNext()
        }
        else if let _ = msg as? ExitMessage {
            self.notify(TextTag("exit\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.cancel()
            self.completed?(self.scriptName, "script exit")
        }
        else if let unkownMsg = msg as? UnknownMessage {
            let txtMsg = TextTag("unkown command: \(unkownMsg.description)\n", mono: true)
            txtMsg.preset = "scripterror"
            self.notify(txtMsg)
            self.moveNext()
        }
        else if let scriptInfo = msg as? ScriptInfoMessage {
            let txtMsg = TextTag(scriptInfo.description, mono: true)
            txtMsg.preset = "scriptinput"
            self.notify(txtMsg)
        }
        else {
            self.notify(TextTag("\(msg.description)\n", mono: true))
            self.moveNext()
        }
    }
    
    public func notify(message: TextTag, debug:ScriptLogLevel = ScriptLogLevel.None) {
        
        if self.logLevel.rawValue < debug.rawValue {
            return
        }
        
        message.scriptName = self.scriptName
        
        if debug != ScriptLogLevel.None {
            let line = self.currentLine != nil ? Int32(self.currentLine!) : -1
            message.scriptLine = line
        }
        
        if message.preset == nil {
            message.preset = "scriptinfo"
        }
        
        self.notifier.notify(message)
    }
    
    public func sendEcho(echo:String) {
        self.notifier.sendEcho("\(echo)\n")
    }
    
    public func sendCommand(command: String) {
        
        let ctx = CommandContext()
        ctx.command = command
        
        ctx.scriptName = self.scriptName
        
        self.notifier.sendCommand(ctx)
    }
    
    func toggleAction(msg:ActionMessage) {
        if let toggle = msg.token.actionToggle {
            
            var filtered = self.actions.filter { a in
                
                return a.token.className.characters.count > 0 && a.token.className == msg.token.className
            }
            
            for index in 0..<filtered.count {
                var action = filtered[index]
                switch toggle {
                case .Off:
                  action.enabled = false
                default:
                   action.enabled = true
                }
            }
        }
    }
    
    func handleEval(evalMsg:EvalMessage) {
        self.notify(TextTag("\(evalMsg.token.description)\n", mono: true), debug:ScriptLogLevel.Vars)
        
        var newVal = ""
       
        if let res = evalMsg.token.lastResult {
            switch res.result {
            case .Boolean(let x):
                newVal = "\(x)"
            case .Str(let x):
                newVal = x
            }
        }
        
        self.setVariable(evalMsg.token.variable, value: newVal)
    }
    
    func handlePut(putMsg:PutMessage) {
        let cmds = putMsg.message.splitToCommands()
        for cmd in cmds {
            self.sendCommand(cmd)
        }
    }
    
    func handleVar(varMsg:VarMessage) {
        self.setVariable(varMsg.identifier, value: varMsg.value)
        self.notify(TextTag("setvariable \(varMsg.identifier) \(varMsg.value)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleSend(sendMsg:SendMessage) {
        //self.notify(TextTag(with: "send \(sendMsg.message)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.sendCommand("#send \(sendMsg.message)")
    }
    
    func handleEcho(echoMsg:EchoMessage) {
        //self.notify(TextTag(with: "echo \(echoMsg.message)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.sendEcho(echoMsg.message)
    }
    
    func handleGoto(gotoMsg:GotoMessage) {
        let params = gotoMsg.params.count > 0 ? gotoMsg.params[0] : ""
        self.notify(TextTag("goto \(gotoMsg.label) \(params)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.gotoLabel(gotoMsg.label, params:gotoMsg.params, previousLine: self.currentLine!)
        self.moveNext()
    }
    
    func handleSave(saveMsg:SaveMessage) {
        self.setVariable("s", value: saveMsg.text)
        self.notify(TextTag("save \(saveMsg.text)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleUnVar(unVarMsg:UnVarMessage) {
        self.context?.removeVariable(unVarMsg.identifier)
        self.notify(TextTag("unvar \(unVarMsg.identifier)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleRandom(randomMsg:RandomMessage) {
        let diceRoll = randomNumberFrom(randomMsg.min...randomMsg.max)
        self.notify(TextTag("random (\(randomMsg.min),\(randomMsg.max)) = \(diceRoll)\n", mono: true), debug:ScriptLogLevel.Vars)
        self.setVariable("r", value: "\(diceRoll)")
    }
    
    func handleMath(mathMsg:MathMessage) {
        
        let current = self.context!.getVariable(mathMsg.variable)?.toDouble() ?? 0
        let result = mathMsg.calcResult(current)
        let strResult = String(format:"%g", result)
        
        self.setVariable(mathMsg.variable, value: "\(strResult)")
        
        self.notify(TextTag("math \(mathMsg.variable): \(current) \(mathMsg.operation) \(mathMsg.number) = \(result)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func setVariable(name:String, value:String) {
        self.context!.setVariable(name, value: value)
        
        self.varsChanged(self.context!.localVarsCopy())
    }
}



public class PauseOp {
    
    var actor:IScript
    var seconds:Double
    
    init(_ actor:IScript, seconds:Double) {
        self.actor = actor
        self.seconds = seconds
    }
    
    public func run() {
        let text = String(format: "pausing for %.02f seconds\n", self.seconds)
        let txtMsg = TextTag(text, mono: true)
        self.actor.notify(txtMsg, debug:ScriptLogLevel.Wait)
        
        after(self.seconds) {
            self.actor.sendMessage(OperationComplete("pause", msg: ""))
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
    
    func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult
    func execute(script:IScript, context:ScriptContext)
}

public protocol IAction : IWantStreamInfo {
    var enabled:Bool {get set}
    var token:ActionToken {get}
    func vars(context:ScriptContext, vars:Dictionary<String, String>) -> CheckStreamResult
}

public class MoveOp : IWantStreamInfo {
    
    public var id = ""
    
    public init() {
        self.id = NSUUID().UUIDString
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        for node in nodes {
            
            if node.name == "compass" {
                return CheckStreamResult.Match(result: "", groups: nil)
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNext()
    }
}

public class NextRoomOp : IWantStreamInfo {
    
    public var id = ""
    
    public init() {
        self.id = NSUUID().UUIDString
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        
        for node in nodes {
            
            if node.name == "compass" {
                return CheckStreamResult.Match(result: "", groups: nil)
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNextAfterRoundtime()
    }
}

public class WaitforOp : IWantStreamInfo {
    
    public var id = ""
    var target:String

    public init(_ target:String) {
        self.id = NSUUID().UUIDString
        self.target = target
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        return text.rangeOfString(context.simplify(self.target)) != nil ? CheckStreamResult.Match(result: text, groups: nil) : CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNextAfterRoundtime()
    }
}

public class WaitforReOp : IWantStreamInfo {

    public var id = ""
    var pattern:String
    var groups:[String]?

    public init(_ pattern:String) {
        self.id = NSUUID().UUIDString
        self.pattern = pattern
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        let pattern = context.simplify(self.pattern)
        let groups = text[pattern].groups()
        self.groups = groups
        return groups.count > 0 ? CheckStreamResult.Match(result: text, groups: groups) : CheckStreamResult.None
    }

    public func execute(script:IScript, context:ScriptContext) {

        if let grps = self.groups {
            context.setRegexVars(grps)
        }
        
        script.moveNextAfterRoundtime()
    }
}

public class WaitforPromptOp : IWantStreamInfo {

    public var id = ""
    
    public init() {
        self.id = NSUUID().UUIDString
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        
        for n in nodes {
            if n.name == "prompt" {
                return CheckStreamResult.Match(result: text, groups: nil)
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNextAfterRoundtime()
    }
}

public class WaitEvalOp : IWantStreamInfo {

    public var id = ""
    private var token:CommandToken
    private var evaluator:ExpressionEvaluator
    
    public init(_ token:CommandToken) {
        self.id = NSUUID().UUIDString
        self.token = token
        self.evaluator = ExpressionEvaluator()
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        
        for n in nodes {
            if n.name == "prompt" {
                let res = self.evaluator.eval(context, self.token.body, context.simplify)
                print("eval res: \(res.info)")
                if getBoolResult(res.result) {
                    return CheckStreamResult.Match(result: res.info, groups: nil)
                }
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNextAfterRoundtime()
    }
    
    private func getBoolResult(result:EvalResult) -> Bool {
        switch(result) {
        case .Boolean(let x):
            return x
        default:
            return false
        }
    }
}

public class ActionOp : IAction {

    public var id = ""
    public var enabled = true
    public var token:ActionToken
    private let tokenToMessage = TokenToMessage()
    private var lastGroups:[String]?
    private var simplify:(Array<Token>)->String
    private var evaluator:ExpressionEvaluator
    private var lastResult:Bool?
    
    public init(_ token:ActionToken, _ simplify:(Array<Token>)->String) {
        self.id = NSUUID().UUIDString
        self.token = token
        self.simplify = simplify
        self.evaluator = ExpressionEvaluator()
    }
    
    public func stream(text:String, nodes:[Node], context:ScriptContext) -> CheckStreamResult {
        
        if self.token.whenText.characters.count == 0 {
            return CheckStreamResult.None
        }

        let whenText = context.simplify(self.token.whenText)

        self.lastGroups = text[whenText].groups()
        return self.lastGroups?.count > 0
            ? CheckStreamResult.Match(result: "action (\(self.token.originalStringLine!+1)) triggered: \(text)\n", groups: nil)
            : CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        
        var vars:[String:String] = [:]
        
        for (index, g) in self.lastGroups?.enumerate() ?? [].enumerate() {
            vars["\(index)"] = g
        }
        
        context.actionVars = vars
        
        for cmd in self.token.commands {
            if let msg = tokenToMessage.toMessage(context, token: cmd) {
                script.sendActionMessage(msg)
            }
        }
        
        context.actionVars = [:]
    }
    
    public func vars(context: ScriptContext, vars: Dictionary<String, String>) -> CheckStreamResult {
        
        if self.token.whenText.characters.count > 0 {
            return CheckStreamResult.None
        }
        
        let res = self.evaluator.eval(context, self.token.when, self.simplify)
        
        if getBoolResult(res.result) {
            self.lastGroups = res.matchGroups
            return CheckStreamResult.Match(result: "action (\(self.token.originalStringLine!+1)) triggered: \(res.info)\n", groups: res.matchGroups)
        }
        
        return CheckStreamResult.None
    }
    
    private func getBoolResult(result:EvalResult) -> Bool {
        switch(result) {
        case .Boolean(let x):
            return x
        default:
            return false
        }
    }
}

public enum CheckStreamResult {
    case None
    case Match(result:String, groups: [String]?)
}

extension Array {
    func forEach(doThis: (element: Element) -> Void) {
        for e in self {
            doThis(element: e)
        }
    }
    
    func find(includedElement: Element -> Bool) -> Int? {
        for (idx, element) in self.enumerate() {
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
        return self.substringFromIndex(self.startIndex.advancedBy(index))
    }
    
    func indexOfCharacter(char: Character) -> Int? {
        if let idx = self.characters.indexOf(char) {
            return self.startIndex.distanceTo(idx)
        }
        return nil
    }
    
    func splitToCommands() -> [String] {
        
        var results:[String] = []
        
        let matches = self["((?<!\\\\);)"].matchResults()
        
        var lastIndex = 0
        let length = self.characters.count
        
        for match in matches {
            let matchLength = match.range.location - lastIndex
            let start = self.startIndex.advancedBy(lastIndex)
            let end = start.advancedBy(matchLength)
            var str = self.substringWithRange(start..<end)
            str = str.stringByReplacingOccurrencesOfString("\\;", withString: ";")
            results.append(str)
            
            lastIndex = match.range.location + match.range.length
        }
        
        if lastIndex < length {
            let start = self.startIndex.advancedBy(lastIndex)
            let end = start.advancedBy(length - lastIndex)
            var str = self.substringWithRange(start ..< end)
            str = str.stringByReplacingOccurrencesOfString("\\;", withString: ";")
            results.append(str)
        }
        
        return results
    }
}

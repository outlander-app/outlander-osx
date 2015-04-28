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
        
        var line = self.currentLine
        var column = self.currentColumn
        
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
            self.notify(TextTag(with: String(format:"+----- '\(self.scriptName)' variables (running for %.02f seconds) -----+\n", diff), mono: true))
            
            var sorted = display.sorted { $0 < $1 }
            
            for v in sorted {
                var tag = TextTag(with: "|  \(v)\n", mono: true)
                self.notify(tag)
            }
            
            self.notify(TextTag(with: "+---------------------------------------------------------+\n", mono: true))
        }
    }
    
    public func setLogLevel(level:ScriptLogLevel) {
        self.logLevel = level
        self.notify(TextTag(with: "[Script '\(self.scriptName)' - setting debug level to \(level.rawValue)]\n", mono: true))
    }
    
    public func varsChanged(vars:[String:String]) {
        var actions = self.actions.filter { x in
            
            if !x.enabled {
                return false
            }
            
            var res = x.vars(vars)
            switch res {
            case .Match(let x):
                self.notify(TextTag(with: x, mono: true), debug:ScriptLogLevel.Actions)
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
        
        if self.paused || self.cancelled {
            return
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
            handler.execute(self, context: self.context!)
        }
        
        var actions = self.actions.filter { x in
            
            if !x.enabled {
                return false
            }
            
            var res = x.stream(text, nodes: nodes)
            switch res {
            case .Match(let x):
                self.notify(TextTag(with: x, mono: true), debug:ScriptLogLevel.Actions)
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
        if let wait = self.matchwait {
            
            var matched = false
            
            for match in self.matchStack {
                if match.isMatch(text) {
                    var label = self.context!.simplify(match.label)
                    self.notify(TextTag(with: "match \(label)\n", mono: true), debug:ScriptLogLevel.Wait)
                    
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
            
            var tag = TextTag(with: "label \(label) not found\n", mono: true)
            
            tag.color = "#efefef"
            tag.backgroundColor = "#ff3300"
            
            self.notify(tag)
        }
    }
    
    private func gosubReturn(moveNext:Bool) {
        if let ctx = self.context!.popGosub() {
            var tag = TextTag(with: "returning to line \(ctx.returnLine + 1)\n", mono: true)
            self.notify(tag, debug: ScriptLogLevel.Gosubs)
            if moveNext {
                self.moveNext()
            }
        } else {
            var tag = TextTag(with: "no gosub to return to!\n", mono: true)
            
            tag.color = "#efefef"
            tag.backgroundColor = "#ff3300"
            
            self.notify(tag)
            self.cancel()
            self.completed?(self.scriptName, "no gosub to return to")
        }
    }
    
    public func run(script:String, globalVars:(()->[String:String])?, params:[String]) {
        
        self.started = NSDate()
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedDate = dateFormatter.stringFromDate(self.started!)
        
        self.sendMessage(ScriptInfoMessage("[Starting '\(self.scriptName)' at \(formattedDate)]\n"))
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let parser = OutlanderScriptParser()
            let tokens = parser.parseString(script)
            
            let parseTime = NSDate().timeIntervalSinceDate(self.started!)
            
            println("parsed \(self.scriptName) in \(parseTime)")
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if parser.errors.count > 0 {
                    
                    for err in parser.errors {
                        var tag = TextTag(with: "\(err)\n", mono: true)
                        tag.color = "#efefef"
                        tag.backgroundColor = "#ff3300"
                        self.notify(tag)
                    }
                    self.cancel()
                    self.completed?(self.scriptName, nil)
                    return
                }
                
                self.context = ScriptContext(tokens, globalVars: globalVars, params: params)
                self.context!.marker.currentIdx = -1
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
        
        var result = self.context!.next()
        if let nextToken = result {
            
            self.currentLine = nextToken.originalStringLine
            
            println("next - \(nextToken.description)")
            
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
                self.notify(TextTag(with: "\(opComplete.description) - \(opComplete.msg)\n", mono: true), debug:ScriptLogLevel.If)
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
            self.notify(TextTag(with: "matchwait\n", mono: true), debug:ScriptLogLevel.Wait)
            self.matchwait = matchwait
        }
        else if let pauseMsg = msg as? PauseMessage {
            var op = PauseOp(self, seconds: pauseMsg.seconds)
            op.run()
        }
        else if let debugMsg = msg as? DebugLevelMessage {
            self.logLevel = debugMsg.level
            self.notify(TextTag(with: "debuglevel \(debugMsg.level.rawValue)\n", mono: true), debug:ScriptLogLevel.Gosubs)
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
            self.notify(TextTag(with: "passing label \(labelMsg.label)\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.moveNext()
        }
        else if let gotoMsg = msg as? GotoMessage {
            self.handleGoto(gotoMsg)
        }
        else if let gosubMsg = msg as? GosubMessage {
            var params = gosubMsg.params.count > 0 ? gosubMsg.params[0] : ""
            self.notify(TextTag(with: "gosub \(gosubMsg.label) \(params)\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.gotoLabel(gosubMsg.label, params:gosubMsg.params, previousLine: self.currentLine!, isGosub:true)
            self.moveNext()
        }
        else if let returnMsg = msg as? ReturnMessage {
            self.gosubReturn(true)
        }
        else if let varMsg = msg as? VarMessage {
            self.handleVar(varMsg)
            self.moveNext()
        }
        else if let waitForMsg = msg as? WaitforMessage {
            self.notify(TextTag(with: "waitfor \(waitForMsg.pattern)\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitforOp(waitForMsg.pattern) )
        }
        else if let waitForMsg = msg as? WaitforReMessage {
            self.notify(TextTag(with: "waitforre \(waitForMsg.pattern)\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitforReOp(waitForMsg.pattern) )
        }
        else if let waitMsg = msg as? WaitMessage {
            self.notify(TextTag(with: "wait\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitforPromptOp() )
        }
        else if let waitEvalMsg = msg as? WaitEvalMessage {
            self.notify(TextTag(with: "waiteval \(waitEvalMsg.token.bodyText())\n", mono: true), debug:ScriptLogLevel.Wait)
            self.addStreamWatcher( WaitEvalOp(waitEvalMsg.token, context!.simplify) )
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
            
            self.notify(TextTag(with: "move \(moveMsg.direction)\n", mono: true), debug:ScriptLogLevel.Wait)
            self.sendCommand(moveMsg.direction)
        }
        else if let moveMsg = msg as? NextRoomMessage {
            self.addStreamWatcher( NextRoomOp() )
            self.notify(TextTag(with: "nextroom\n", mono: true), debug:ScriptLogLevel.Wait)
        }
        else if let shiftMsg = msg as? ShiftMessage {
            var res = self.context!.shiftParamVars()
            if res {
                self.notify(TextTag(with: "shift\n", mono: true), debug:ScriptLogLevel.Vars)
                self.moveNext()
            } else {
                let txtMsg = TextTag(with: "no more params to shift!\n", mono: true)
                txtMsg.color = "#efefef"
                txtMsg.backgroundColor = "#ff3300"
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
            
            if let toggle = actionMsg.token.actionToggle {
                self.toggleAction(actionMsg)
                self.notify(TextTag(with: "action (\(actionMsg.token.className)) \(actionMsg.token.commandText())\n", mono: true), debug:ScriptLogLevel.Actions)
            } else {
                self.notify(TextTag(with: "action \(actionMsg.token.commandText()) when \(actionMsg.token.whenText)\n", mono: true), debug:ScriptLogLevel.Actions)
                self.actions.append(ActionOp(actionMsg.token, self.context!.simplify))
            }
            
            self.moveNext()
        }
        else if let actionInfoMsg = msg as? ActionInfoMessage {
            self.notify(TextTag(with: "action - \(actionInfoMsg.msg)\n", mono: true), debug:ScriptLogLevel.Actions)
        }
        else if let commentMsg = msg as? CommentMessage {
            self.moveNext()
        }
        else if let exitMsg = msg as? ExitMessage {
            self.notify(TextTag(with: "exit\n", mono: true), debug:ScriptLogLevel.Gosubs)
            self.cancel()
            self.completed?(self.scriptName, "script exit")
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
    
    public func notify(message: TextTag, debug:ScriptLogLevel = ScriptLogLevel.None) {
        
        if self.logLevel.rawValue < debug.rawValue {
            return
        }
        
        message.scriptName = self.scriptName
        
        if debug != ScriptLogLevel.None {
            var line = self.currentLine != nil ? Int32(self.currentLine!) : -1
            message.scriptLine = line
        }
        
        if message.color == nil {
            message.color = "#0066cc"
        }
        
        message.preset = "scriptinput"
        
        self.notifier.notify(message)
    }
    
    public func sendEcho(echo:String) {
        self.notifier.sendEcho("\(echo)\n")
    }
    
    public func sendCommand(command: String) {
        
        var ctx = CommandContext()
        ctx.command = command
        
        ctx.scriptName = self.scriptName
        
        self.notifier.sendCommand(ctx)
    }
    
    func toggleAction(msg:ActionMessage) {
        if let toggle = msg.token.actionToggle {
            
            var filtered = self.actions.filter { a in
                
                return count(a.token.className) > 0 && a.token.className == msg.token.className
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
        self.notify(TextTag(with: "\(evalMsg.token.description)\n", mono: true), debug:ScriptLogLevel.Vars)
        
        var newVal = ""
       
        if let res = evalMsg.token.lastResult {
            switch res.result {
            case .Boolean(let x):
                newVal = "\(x)"
            case .Str(let x):
                newVal = x
            default:
                newVal = ""
            }
        }
        
        self.setVariable(evalMsg.token.variable, value: newVal)
    }
    
    func handlePut(putMsg:PutMessage) {
        
        //self.notify(TextTag(with: "put \(putMsg.message)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        let cmds = putMsg.message.componentsSeparatedByString(";")
        for cmd in cmds {
            self.sendCommand(cmd)
        }
    }
    
    func handleVar(varMsg:VarMessage) {
        self.setVariable(varMsg.identifier, value: varMsg.value)
        self.notify(TextTag(with: "setvariable \(varMsg.identifier) \(varMsg.value)\n", mono: true), debug:ScriptLogLevel.Vars)
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
        var params = gotoMsg.params.count > 0 ? gotoMsg.params[0] : ""
        self.notify(TextTag(with: "goto \(gotoMsg.label) \(params)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.gotoLabel(gotoMsg.label, params:gotoMsg.params, previousLine: self.currentLine!)
        self.moveNext()
    }
    
    func handleSave(saveMsg:SaveMessage) {
        self.setVariable("s", value: saveMsg.text)
        self.notify(TextTag(with: "save \(saveMsg.text)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleUnVar(unVarMsg:UnVarMessage) {
        self.context?.removeVariable(unVarMsg.identifier)
        self.notify(TextTag(with: "unvar \(unVarMsg.identifier)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleRandom(randomMsg:RandomMessage) {
        let diceRoll = randomNumberFrom(randomMsg.min...randomMsg.max)
        self.notify(TextTag(with: "random (\(randomMsg.min),\(randomMsg.max)) = \(diceRoll)\n", mono: true), debug:ScriptLogLevel.Vars)
        self.setVariable("r", value: "\(diceRoll)")
    }
    
    func handleMath(mathMsg:MathMessage) {
        
        var current = self.context!.getVariable(mathMsg.variable)?.toDouble() ?? 0
        var result = mathMsg.calcResult(current)
        var strResult = String(format:"%g", result)
        
        self.setVariable(mathMsg.variable, value: "\(strResult)")
        
        self.notify(TextTag(with: "math \(mathMsg.variable): \(current) \(mathMsg.operation) \(mathMsg.number) = \(result)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func setVariable(name:String, value:String) {
        self.context!.setVariable(name, value: value)
        
        self.varsChanged(self.context!.localVarsCopy())
    }
}

public class TokenToMessage {
    
    public func toMessage(context:ScriptContext, token:Token) -> Message? {
        
        var msg:Message? = UnknownMessage(token.description)
        
        if let branch = token as? BranchToken {
            
            msg = OperationComplete(branch.name, msg: branch.lastResult?.info ?? "")
            
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
                
            case _ where cmd.name == "eval":
                msg = EvalMessage(cmd as! EvalCommandToken)
                
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
                
            case "send":
                msg = SendMessage(
                    context
                        .simplifyEach(cmd.body)
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                )
                
            case "pause":
                var lengthStr = cmd.bodyText()
                msg = PauseMessage(lengthStr.toDouble() ?? 1)
                
            case _ where cmd.name == "debuglevel" || cmd.name == "debug":
                var levelStr = cmd.bodyText()
                msg = DebugLevelMessage(levelStr.toInt() ?? ScriptLogLevel.Actions.rawValue)
                
            case "math":
                
                var variable = ""
                var operation = ""
                var number:Double = 0
                
                var evaled = context.simplify(cmd.bodyText()).componentsSeparatedByString(" ")
                
                if evaled.count > 2 {
                    variable = evaled[0]
                    operation = evaled[1]
                    number = evaled[2].toDouble() ?? 0
                }
                
                msg = MathMessage(variable, operation, number)
                
            case _ where cmd.name == "unvar":
                var txt = context.simplify(cmd.bodyText())
                msg = UnVarMessage(txt)
                
            case "var", "setvariable":
                
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var identifier = context.simplify(txt.removeAtIndex(0))
                var value = context.simplify(" ".join(txt))
                
                msg = VarMessage(identifier, value)
                
            case "save":
                var txt = context.simplify(cmd.bodyText())
                msg = SaveMessage(txt)

            case _ where cmd.name == "matchwait":
                var timeoutStr = cmd.bodyText()
                msg = MatchwaitMessage(timeoutStr.toDouble())

            case _ where cmd.name == "matchre":
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var label = txt.removeAtIndex(0)
                var value = " ".join(txt)
                msg = MatchReMessage(label, value)
                
            case _ where cmd.name == "match":
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var label = txt.removeAtIndex(0)
                var value = " ".join(txt)
                
                msg = MatchMessage(label, value)
                
            case _ where cmd.name == "waitforre":
                msg = WaitforReMessage(cmd.bodyText())
                
            case _ where cmd.name == "waitfor":
                msg = WaitforMessage(cmd.bodyText())
                
            case _ where cmd.name == "wait":
                msg = WaitMessage()
                
            case _ where cmd.name == "waiteval":
                msg = WaitEvalMessage(cmd)
                
            case "gosub":
                var args = context.simplifyEach(cmd.body)
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    .componentsSeparatedByString(" ")
                
                var label = args.removeAtIndex(0)
                var allArgs = " ".join(args)
                args.insert(allArgs, atIndex: 0)
                
                msg = GosubMessage(label, args)
                
            case "random":
                var nums = cmd.bodyText().componentsSeparatedByString(" ")
                
                var min = 0
                var max = 1
                
                if nums.count > 1 {
                    min = nums[0].toInt() ?? 0
                    max = nums[1].toInt() ?? 1
                }
                
                msg = RandomMessage(min, max)
            
            case "return":
                msg = ReturnMessage()
                
            case "nextroom":
                msg = NextRoomMessage()
                
            case "move":
                var direction = context.simplifyEach(cmd.body)
                msg = MoveMessage(direction.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                
            case "shift":
                msg = ShiftMessage()
                
            case "exit":
                msg = ExitMessage()
                
            case "action":
                msg = ActionMessage(cmd as! ActionToken)
                
            default:
                msg = UnknownMessage(token.description)
            }
        } else if let comment = token as? CommentToken {
            msg = CommentMessage()
        }
        
        return msg
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
        var text = String(format: "pausing for %.02f seconds\n", self.seconds)
        var txtMsg = TextTag(with: text, mono: true)
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
    
    func stream(text:String, nodes:[Node]) -> CheckStreamResult
    func execute(script:IScript, context:ScriptContext)
}

public protocol IAction : IWantStreamInfo {
    var enabled:Bool {get set}
    var token:ActionToken {get}
    func vars(vars:Dictionary<String, String>) -> CheckStreamResult
}

public class MoveOp : IWantStreamInfo {
    
    public var id = ""
    
    public init() {
        self.id = NSUUID().UUIDString
    }
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        for node in nodes {
            
            if node.name == "compass" {
                return CheckStreamResult.Match(result: "")
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
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        
        for node in nodes {
            
            if node.name == "compass" {
                return CheckStreamResult.Match(result: "")
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
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
    
    public func execute(script:IScript, context:ScriptContext) {
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
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNext()
    }
}

public class WaitforPromptOp : IWantStreamInfo {

    public var id = ""
    
    public init() {
        self.id = NSUUID().UUIDString
    }
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        
        for n in nodes {
            if n.name == "prompt" {
                return CheckStreamResult.Match(result: text)
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNext()
    }
}

public class WaitEvalOp : IWantStreamInfo {

    public var id = ""
    private var token:CommandToken
    private var simplify:(Array<Token>)->String
    private var evaluator:ExpressionEvaluator
    
    public init(_ token:CommandToken, _ simplify:(Array<Token>)->String) {
        self.id = NSUUID().UUIDString
        self.token = token
        self.simplify = simplify
        self.evaluator = ExpressionEvaluator()
    }
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        
        for n in nodes {
            if n.name == "prompt" {
                let res = self.evaluator.eval(self.token.body, self.simplify)
                println("eval res: \(res.info)")
                if getBoolResult(res.result) {
                    return CheckStreamResult.Match(result: res.info)
                }
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNext()
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
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        
        if count(self.token.whenText) > 0 {
            self.lastGroups = text[self.token.whenText].groups()
            return self.lastGroups?.count > 0
                ? CheckStreamResult.Match(result: "action (\(self.token.originalStringLine!+1)) triggered: \(text)\n")
                : CheckStreamResult.None
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        
        var vars:[String:String] = [:]
        
        for (index, g) in enumerate(self.lastGroups ?? []) {
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
    
    public func vars(vars: Dictionary<String, String>) -> CheckStreamResult {
        
        if count(self.token.whenText) > 0 {
            return CheckStreamResult.None
        }
        
        let res = self.evaluator.eval(self.token.when, self.simplify)
        
        if getBoolResult(res.result) {
            self.lastGroups = res.matchGroups
            return CheckStreamResult.Match(result: "action (\(self.token.originalStringLine!+1)) triggered: \(res.info)\n")
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

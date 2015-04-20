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
    var logLevel:ScriptLogLevel { get set }
  
    func printInfo()
    func cancel()
    func pause()
    func resume()
    func vars()
    func notify(message: TextTag, debug:ScriptLogLevel)
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
    case Gosubs = 1
    case Wait = 2
    case If = 3
    case Vars = 4
    case Actions = 5
}

public class Script : BaseOp, IScript {
  
    public var scriptName:String
    public var logLevel = ScriptLogLevel.None
    
    var notifier:INotifyMessage
    var actor:Actor
    var context:ScriptContext?
    var started:NSDate?
    
    private var nextAfterUnpause = false
    private var matchStack:[IMatch]
    private var matchwait:MatchwaitMessage?
    
    private var actions:[IWantStreamInfo]
    private var reactToStream:[IWantStreamInfo]
    
    let tokenToMessage = TokenToMessage()
    var currentLine:Int?
    var currentColumn:Int?
    
    public init(_ scriptName:String, _ notifier:INotifyMessage, _ actor:Actor) {
        self.scriptName = scriptName
        self.notifier = notifier
        self.actor = actor
        self.matchStack = []
        self.actions = []
        self.reactToStream = []
    }
    
    public override func main () {
        autoreleasepool {
            
            self.started = NSDate()
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "hh:mm a"
            let formattedDate = dateFormatter.stringFromDate(self.started!)
            
            self.sendMessage(ScriptInfoMessage("[Starting '\(self.scriptName)' at \(formattedDate)]\n"))
            
            while !self.cancelled {
            }
            
            self.currentLine = nil
            self.currentColumn = nil
            
            let diff = NSDate().timeIntervalSinceDate(self.started!)
            
            self.sendMessage(ScriptInfoMessage(String(format: "[Script '\(self.scriptName)' completed after %.02f seconds total run time]\n", diff)))
        }
    }
    
    public func printInfo() {
        let diff = NSDate().timeIntervalSinceDate(self.started!)
        self.sendMessage(ScriptInfoMessage(String(format: "[Script '\(self.scriptName)' running for %.02f seconds]\n", diff)))
    }
    
    override public func pause() {
       
        // LLVM BUG: if these two lines are after super.pause(), it causes a segmentation fault when archived
        let line = self.currentLine
        let column = self.currentColumn
        
        super.pause()
        
        self.currentLine = nil
        self.currentColumn = nil
        
        self.sendMessage(ScriptInfoMessage("[Pausing '\(self.scriptName)']\n"))
        
        self.currentLine = line
        self.currentColumn = column
    }
    
    override public func resume() {
        var line = self.currentLine
        var column = self.currentColumn
        
        self.currentLine = nil
        self.currentColumn = nil
        
        self.sendMessage(ScriptInfoMessage("[Resuming '\(self.scriptName)']\n"))
        
        self.currentLine = line
        self.currentColumn = column
        
        super.resume()
        
        if nextAfterUnpause {
            nextAfterUnpause = false
            self.moveNext()
        }
    }
    
    public func vars() {
        if let display = self.context?.varsForDisplay() {
            
            let diff = NSDate().timeIntervalSinceDate(self.started!)
            self.notify(TextTag(with: String(format:"+----- Script Variables (running for %.02f seconds) -----+\n", diff), mono: true))
            
            for v in display {
                var tag = TextTag(with: "|  \(v)\n", mono: true)
                self.notify(tag)
            }
            
            self.notify(TextTag(with: "+---------------------------------------------------------+\n", mono: true))
        }
    }
    
    public func stream(text:String, nodes:[Node]) {
        
        if self._paused || self.cancelled {
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
                    self.gotoLabel(label, params:match.groups, previousLine:-1, isGosub:false)
                    
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
    
    private func gosubReturn() {
        if let ctx = self.context!.popGosub() {
            var tag = TextTag(with: "returning to line \(ctx.returnLine + 1)\n", mono: true)
            self.notify(tag, debug: ScriptLogLevel.Gosubs)
            self.moveNext()
        } else {
            var tag = TextTag(with: "no gosub to return to!\n", mono: true)
            
            tag.color = "#efefef"
            tag.backgroundColor = "#ff3300"
            
            self.notify(tag)
            self.cancel()
        }
    }
    
    public func run(script:String, globalVars:(()->[String:String])?, params:[String]) {
        
        try {
            let parser = OutlanderScriptParser()
            let tokens = parser.parseString(script)
            
            if parser.errors.count > 0 {
                
                for err in parser.errors {
                    var tag = TextTag(with: "\(err)\n", mono: true)
                    tag.color = "#efefef"
                    tag.backgroundColor = "#ff3300"
                    self.notify(tag)
                }
                self.cancel()
                return
            }
            
            self.context = ScriptContext(tokens, globalVars: globalVars, params: params)
            self.context!.marker.currentIdx = -1
            self.moveNext()
            
        }.catch { e in
           
            var tag = TextTag(with: "\(e)\n", mono: true)
            tag.color = "#efefef"
            tag.backgroundColor = "#ff3300"
            self.notify(tag)
            self.cancel()
        }
        
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
            self.actor.addOperation(PauseOp(self, seconds: pauseMsg.seconds))
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
            self.gosubReturn()
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
        else if let actionMsg = msg as? ActionMessage {
            self.actions.append(ActionOp(actionMsg.token))
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
        
        var line = self.currentLine != nil ? Int32(self.currentLine!) : -1
        message.scriptLine = line
        
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
        
        var line = self.currentLine != nil ? Int32(self.currentLine!) : -1
        ctx.scriptName = self.scriptName
        ctx.scriptLine = line
        
        self.notifier.sendCommand(ctx)
    }
    
    func handlePut(putMsg:PutMessage) {
        self.notify(TextTag(with: "put \(putMsg.message)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.sendCommand(putMsg.message)
    }
    
    func handleVar(varMsg:VarMessage) {
        var res = self.context!.simplify(varMsg.value)
        self.context?.setVariable(varMsg.identifier, value: res)
        self.notify(TextTag(with: "setvariable \(varMsg.identifier) \(res)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleSend(sendMsg:SendMessage) {
        self.notify(TextTag(with: "send \(sendMsg.message)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.sendCommand("#send \(sendMsg.message)")
    }
    
    func handleEcho(echoMsg:EchoMessage) {
        self.notify(TextTag(with: "echo \(echoMsg.message)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.sendEcho(echoMsg.message)
    }
    
    func handleGoto(gotoMsg:GotoMessage) {
        var params = gotoMsg.params.count > 0 ? gotoMsg.params[0] : ""
        self.notify(TextTag(with: "goto \(gotoMsg.label) \(params)\n", mono: true), debug:ScriptLogLevel.Gosubs)
        self.gotoLabel(gotoMsg.label, params:gotoMsg.params, previousLine: self.currentLine!)
        self.moveNext()
    }
    
    func handleSave(saveMsg:SaveMessage) {
        var res = self.context!.simplify(saveMsg.text)
        self.context?.setVariable("s", value: res)
        self.notify(TextTag(with: "save \(res)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleUnVar(unVarMsg:UnVarMessage) {
        var res = self.context!.simplify(unVarMsg.identifier)
        self.context?.removeVariable(res)
        self.notify(TextTag(with: "unvar \(res)\n", mono: true), debug:ScriptLogLevel.Vars)
    }
    
    func handleRandom(randomMsg:RandomMessage) {
        let diceRoll = randomNumberFrom(randomMsg.min...randomMsg.max)
        self.notify(TextTag(with: "random (\(randomMsg.min),\(randomMsg.max)) = \(diceRoll)\n", mono: true), debug:ScriptLogLevel.Vars)
        self.context?.setVariable("r", value: "\(diceRoll)")
    }
    
    func handleMath(mathMsg:MathMessage) {
        
        var current = self.context!.getVariable(mathMsg.variable)?.toDouble() ?? 0
        var result = mathMsg.calcResult(current)
        
        self.context!.setVariable(mathMsg.variable, value: "\(result)")
        
        self.notify(TextTag(with: "math \(current) \(mathMsg.operation) \(mathMsg.number) = \(result)\n", mono: true), debug:ScriptLogLevel.Vars)
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
                
            case "debuglevel":
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
                var txt = cmd.bodyText()
                msg = UnVarMessage(txt)
                
            case "var", "setvariable":
                
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                var identifier = txt.removeAtIndex(0)
                var value = " ".join(txt)
                
                msg = VarMessage(identifier, value)
                
            case "save":
                var txt = cmd.bodyText()
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
            self.actor.notify(txtMsg, debug:ScriptLogLevel.Wait)
            
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
    func execute(script:IScript, context:ScriptContext)
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
                if res.result {
                    return CheckStreamResult.Match(result: res.info)
                }
            }
        }
        
        return CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        script.moveNext()
    }
}

public class ActionOp : IWantStreamInfo {

    public var id = ""
    private var token:ActionToken
    private let tokenToMessage = TokenToMessage()
    private var lastGroups:[String]
    
    public init(_ token:ActionToken) {
        self.id = NSUUID().UUIDString
        self.token = token
        self.lastGroups = []
    }
    
    public func stream(text:String, nodes:[Node]) -> CheckStreamResult {
        self.lastGroups = text[self.token.whenText].groups()
        return self.lastGroups.count > 0
            ? CheckStreamResult.Match(result: "action (\(self.token.originalStringLine!)) triggered by \(text)\n")
            : CheckStreamResult.None
    }
    
    public func execute(script:IScript, context:ScriptContext) {
        
        var vars:[String:String] = [:]
        
        for (index, g) in enumerate(self.lastGroups) {
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

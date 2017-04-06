//
//  Script.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

func delay(_ delay: Double, _ closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

enum CheckStreamResult {
    case None
    case Match(result:String)
}

protocol IWantStreamInfo {

    var id:String { get }

    func stream(_ text:String, _ nodes:[Node], _ context:ScriptContext) -> CheckStreamResult
    func execute(_ script:IScript, _ context:ScriptContext)
}

protocol IAction : IWantStreamInfo {
    var enabled:Bool {get set}
//    var token:ActionToken {get}
    func vars(context:ScriptContext, vars:Dictionary<String, String>) -> CheckStreamResult
}

protocol IMatch {
    var value:String {get}
    var label:String {get}
    var groups:[String] {get}

    func isMatch(text:String, _ simplify: (String)->String) -> Bool
}

protocol IScript {
    var fileName:String { get }
    func stop()
    func resume()
    func pause()
    func setLogLevel(_ level:ScriptLogLevel)
    func next()
    func nextAfterRoundtime()
    func stream(_ text:String, _ nodes:[Node])
    func vars()
}

struct Label {
    var name: String
    var line: Int
    var fileName: String
}

struct ScriptLine {
    var originalText: String
    var fileName: String
    var lineNumber: Int
    var token:TokenValue?
}

class ScriptContext {
    var lines: [ScriptLine] = []
    var labels: [String:Label] = [:]
    var currentLineNumber:Int = -1
    var params:[String] = []
    var paramVars: [String:String] = [:]
    var variables: [String:String] = [:]

    var globalVar:((String) -> String?) = { _ in nil }

    var currentLine:ScriptLine? {
        get {
            if currentLineNumber == -1 || currentLineNumber >= lines.count {
                return nil
            }

            return lines[currentLineNumber]
        }
    }

    func advance() {
        currentLineNumber += 1
    }

    func simplify(_ text:String) -> String {
        return text
    }
}

enum ScriptExecuteResult {
    case next
    case wait
    case exit
}

class Script : IScript {
    let labelRegex: Regex
    let includeRegex: Regex

    let fileName: String
    let loader: (String) -> [String]
    let gameContext: GameContext
    let context: ScriptContext
    let notifyExit: () -> ()

    var started:Date?
    var debugLevel:ScriptLogLevel = ScriptLogLevel.none
    var stopped = false
    var paused = false
    var nextAfterUnpause = false

    private var tokenHandlers:[TokenValue:(TokenValue)->ScriptExecuteResult]
    private var reactToStream:[IWantStreamInfo]

    private var args:[String]
    private var argVars:[String:String]
    private var variables:[String:String]
    private var lastToken:TokenValue?

    init(_ loader: @escaping ((String) -> [String]),
         _ fileName: String,
         _ gameContext: GameContext,
         _ notifyExit: @escaping ()->()) throws {
        self.loader = loader
        self.fileName = fileName
        self.gameContext = gameContext
        self.context = ScriptContext()
        self.context.globalVar = { variable in
            return gameContext.globalVars.cacheObject(forKey: variable) as? String
        }
        
        self.notifyExit = notifyExit

        labelRegex = try Regex("^\\s*(\\w+((\\.|-|\\w)+)?):")
        includeRegex = try Regex("^\\s*include (.+)$")

        self.reactToStream = []
        self.args = []
        self.argVars = [:]
        self.variables = [:]
        
        self.tokenHandlers = [:]
        self.tokenHandlers[.comment("")] = self.handleComment
        self.tokenHandlers[.debug(0)] = self.handleDebug
        self.tokenHandlers[.echo("")] = self.handleEcho
        self.tokenHandlers[.exit] = self.handleExit
        self.tokenHandlers[.goto("")] = self.handleGoto
        self.tokenHandlers[.ifArgSingle(0, .comment(""))] = self.handleIfArgSingle
        self.tokenHandlers[.label("")] = self.handleLabel
        self.tokenHandlers[.move("")] = self.handleMove
        self.tokenHandlers[.nextroom] = self.handleNextroom
        self.tokenHandlers[.pause(0)] = self.handlePause
        self.tokenHandlers[.put("")] = self.handlePut
        self.tokenHandlers[.save("")] = self.handleSave
        self.tokenHandlers[.send("")] = self.handleSend
        self.tokenHandlers[.shift] = self.handleShift
        self.tokenHandlers[.unvar("")] = self.handleUnvar
        self.tokenHandlers[.wait] = self.handleWait
        self.tokenHandlers[.waitfor("")] = self.handleWaitfor
        self.tokenHandlers[.waitforre("")] = self.handleWaitforre
        self.tokenHandlers[.variable("", "")] = self.handleVariable
    }

    func run(_ args:[String]) {

        self.args = args
        self.updateArgumentVars()

        self.started = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedDate = dateFormatter.string(from: self.started!)

        self.sendText(String(format:"[Starting '\(self.fileName)' at \(formattedDate)]\n"))
        self.sendText(String(format:"[\(Date()) - started]\n"))
        
        initialize(self.fileName, context: self.context)

        self.sendText(String(format:"[\(Date()) - initialized]\n"))

        self.variables["scriptname"] = self.fileName

        next()
    }

    fileprivate func initialize(_ fileName: String, context: ScriptContext) {
        let lines = self.loader(fileName)

//        print("line count: \(lines.count)")

        if lines.count == 0 {
            sendText("Script '\(fileName)' is empty or does not exist\n", preset: "scripterror")
            return
        }

        var index = 0

        for line in lines {
            index += 1

            if line == "" {
                continue
            }

            if let include = includeRegex.firstMatch(line as NSString) {
                let includeName = include.trimmingCharacters(in: CharacterSet.whitespaces).trimSuffix(".cmd")
                guard includeName != fileName else {
                    sendText("script '\(fileName)' cannot include itself!\n", preset: "scripterror", fileName: fileName, scriptLine: index)
                    continue
                }
                print("\(includeName)(\(index))")
                self.notify("including '\(includeName)'\n", debug: ScriptLogLevel.gosubs, scriptLine: index)
                initialize(includeName, context: context)
            } else {
                let scriptLine = ScriptLine(originalText: line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), fileName: fileName, lineNumber: index, token: nil)
                context.lines.append(scriptLine)
            }

            if let label = labelRegex.firstMatch(line as NSString) {
                if let existing  = context.labels[label] {
                    sendText("replacing label '\(existing.name)' from '\(existing.fileName)'\n", preset: "scripterror", fileName: fileName, scriptLine: index)
                }
                context.labels[label.lowercased()] = Label(name: label.lowercased(), line: context.lines.count - 1, fileName: fileName)
            }
        }
    }

    public func sendCommand(_ command: String) {

        let ctx = CommandContext()
        ctx.command = command
        ctx.scriptName = self.fileName

        self.gameContext.events.sendCommand(ctx)
    }

    func sendText(_ text:String, mono:Bool = true, preset:String = "scriptinput", fileName:String = "", scriptLine:Int = -1) {
        let tag = TextTag()
        tag.text = text
        tag.mono = mono
        tag.preset = preset
        tag.scriptName = fileName
        tag.scriptLine = Int32(scriptLine)
        self.gameContext.events.sendText(tag)
    }

    public func notify(_ text: String, mono:Bool = true, preset:String = "scriptinfo", debug:ScriptLogLevel = ScriptLogLevel.none, scriptLine:Int = -1) {

        if self.debugLevel.rawValue < debug.rawValue {
            return
        }

        let message = TextTag()
        message.text = text
        message.mono = mono
        message.scriptName = self.fileName
        message.preset = preset
        message.scriptLine = Int32(scriptLine)

        if debug != ScriptLogLevel.none {
            if let line = self.context.currentLine {
                message.scriptLine = Int32(line.lineNumber)
            }
        }

        self.gameContext.events.sendText(message)
    }

    func printInfo() {
        let diff = Date().timeIntervalSince(self.started!)
        self.sendText(String(format: "[Script '\(self.fileName)' running for %.02f seconds]\n", diff), preset: "scriptinput")
    }

    func varsForDisplay() -> [String] {
        var vars:[String] = []

        for (key, value) in self.argVars {
            vars.append("\(key): \(value)")
        }

        for (key, value) in self.variables {
            vars.append("\(key): \(value)")
        }

        return vars.sorted { $0 < $1 }
    }

    func shiftArgumentVars() -> Bool {
        guard let _ = self.args.first else {
            return false
        }

        self.args.remove(at: 0)
        self.updateArgumentVars()
        return true
    }

    func updateArgumentVars() {
        self.argVars = [:]

        var all = ""

        for param in self.args {
            if param.contains(" ") {
                all += " \"\(param)\""
            } else {
                all += " \(param)"
            }
        }

        self.argVars["0"] = all.trimmingCharacters(in: CharacterSet.whitespaces)

        for (index, param) in self.args.enumerated() {
            self.argVars["\(index+1)"] = param
        }

        let originalCount = self.args.count

        let maxArgs = 9

        let diff = maxArgs - originalCount

        if(diff > 0) {
            let start = maxArgs - diff
            for index in start..<(maxArgs) {
                self.argVars["\(index+1)"] = ""
            }
        }

        self.variables["argcount"] = "\(originalCount)"
    }

    func vars() {
        let display = self.varsForDisplay()

        let diff = Date().timeIntervalSince(self.started!)
        self.sendText(
            String(format:"+----- '\(self.fileName)' variables (running for %.02f seconds) -----+\n", diff),
                mono: true,
                preset: "scriptinfo")

        for v in display {
            self.sendText("|  \(v)\n", mono: true, preset: "scriptinfo")
        }

        self.sendText("+---------------------------------------------------------+\n", mono: true, preset: "scriptinfo")
    }

    func stop() {

        if self.stopped { return }
        
        self.stopped = true
        self.context.currentLineNumber = -1
        let diff = Date().timeIntervalSince(self.started!)
        self.sendText(String(format: "[Script '\(self.fileName)' completed after %.02f seconds total run time]\n", diff), preset: "scriptinput")
    }

    func cancel() {
        self.stop()
        self.notifyExit()
    }

    func pause() {
        self.paused = true
        self.sendText("[Pausing '\(self.fileName)']\n")
    }

    func resume() {
        if !self.paused {
            return
        }

        self.sendText("[Resuming '\(self.fileName)']\n")

        self.paused = false

        if self.nextAfterUnpause {
            self.next()
        }
    }

    func setLogLevel(_ level:ScriptLogLevel) {
        self.debugLevel = level
        self.sendText("[Script '\(self.fileName)' - setting debug level to \(level.rawValue)]\n")
    }

    func stream(_ text:String, _ nodes:[Node]) {
        if (text.characters.count == 0 && nodes.count == 0) || self.paused || self.stopped {
            return
        }

        let handlers = self.reactToStream.filter { x in
            let res = x.stream(text, nodes, self.context)
            switch res {
            case .Match:
                return true
            default:
                return false
            }
        }

        handlers.forEach { handler in
            let idx = self.reactToStream.find { $0.id == handler.id  }
            self.reactToStream.remove(at: idx!)
            handler.execute(self, self.context)
        }
    }

    func next() {

        if self.stopped { return }

        if self.paused {
            self.nextAfterUnpause = true
            return
        }
        
        self.context.advance()

        guard var line = self.context.currentLine else {
            self.cancel()
            return
        }

        if line.token == nil {
            line.token = ScriptParser().parse(line.originalText)
        }

        let result = handleLine(line)

        switch (result) {
            case .next: next()
            case .wait: return
            case .exit: self.cancel()
        }
    }

    func nextAfterRoundtime() {
        self.next()
    }

    func handleLine(_ line:ScriptLine) -> ScriptExecuteResult {
        guard let token = line.token else {
            self.sendText("Unknown command: '\(line.originalText)'\n", preset: "scripterror", fileName: self.fileName, scriptLine: line.lineNumber - 1)
            return .next
        }

        self.lastToken = token

        if let handler = self.tokenHandlers[token] {
            return handler(token)
        }

        self.sendText("No handler for script token: '\(line.originalText)'\n", preset: "scripterror", fileName: self.fileName, scriptLine: line.lineNumber - 1)
        return .exit
    }

    func handleToken(_ token:TokenValue) -> ScriptExecuteResult {
        if let handler = self.tokenHandlers[token] {
            return handler(token)
        }

        self.sendText("No handler for script token: '\(token)'\n", preset: "scripterror", fileName: self.fileName)
        return .exit
    }

    func handleComment(_ token:TokenValue) -> ScriptExecuteResult {
        guard case .comment(_) = token else {
            return .next
        }

        return .next
    }
    
    func handleDebug(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .debug(level) = token else {
            return .next
        }

        self.debugLevel = ScriptLogLevel(rawValue: level) ?? ScriptLogLevel.none
        self.notify("debug \(self.debugLevel.rawValue)\n", debug:ScriptLogLevel.gosubs)

        return .next
    }

    func handleEcho(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .echo(text) = token else {
            return .next
        }

        self.gameContext.events.echoText(text)
        return .next
    }

    func handleExit(_ token:TokenValue) -> ScriptExecuteResult {
        guard case .exit = token else {
            return .next
        }

        self.notify("exit\n", debug:ScriptLogLevel.gosubs)

        return .exit
    }

    func handleGoto(_ token:TokenValue) -> ScriptExecuteResult {

        guard case let .goto(label) = token else {
            return .next
        }

        guard let target = self.context.labels[label.lowercased()] else {
            self.notify("label '\(label)' not found", preset: "scripterror", debug:ScriptLogLevel.gosubs)
            return .exit
        }

        self.notify("goto '\(label)'\n", debug:ScriptLogLevel.gosubs)
        self.context.currentLineNumber = target.line - 1

        return .next
    }

    func handleIfArgSingle(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .ifArgSingle(count, lineToken) = token else {
            return .next
        }

        let hasArgs = self.args.count >= count
        
        self.notify("if_\(count) \(self.args.count) >= \(count) = \(hasArgs)\n", debug:ScriptLogLevel.if)

        if hasArgs {
            return handleToken(lineToken)
        }

        return .next
    }

    func handleLabel(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .label(label) = token else {
            return .next
        }

        self.notify("passing label '\(label)'\n", debug:ScriptLogLevel.gosubs)
        return .next
    }

    func handleMove(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .move(dir) = token else {
            return .next
        }

        self.notify("move \(dir)\n", debug:ScriptLogLevel.wait)
        self.reactToStream.append(MoveOp())
        self.sendCommand("\(dir)")

        return .wait
    }

    func handleNextroom(_ token:TokenValue) -> ScriptExecuteResult {
        guard case .nextroom = token else {
            return .next
        }

        self.notify("nextroom\n", debug:ScriptLogLevel.wait)
        self.reactToStream.append(NextRoomOp())

        return .wait
    }

    func handlePause(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .pause(duration) = token else {
            return .next
        }

        self.notify("pausing for \(duration) seconds\n", debug:ScriptLogLevel.wait)
        delay(duration) {
            self.next()
        }

        return .wait
    }

    func handlePut(_ token:TokenValue) -> ScriptExecuteResult {

        guard case let .put(text) = token else {
            return .next
        }

        let cmds = text.splitToCommands()
        for cmd in cmds {
            self.sendCommand(cmd)
        }

        return .next
    }

    func handleSave(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .save(text) = token else {
            return .next
        }
        self.notify("save \(text) to %s\n", debug:ScriptLogLevel.wait)
        self.variables["s"] = text
        return .next
    }

    func handleSend(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .send(text) = token else {
            return .next
        }
        self.sendCommand("#send \(text)")
        return .next
    }

    func handleShift(_ token:TokenValue) -> ScriptExecuteResult {
        guard case .shift = token else {
            return .next
        }

        self.notify("shift\n", debug:ScriptLogLevel.vars)

        if !self.shiftArgumentVars() {
            self.sendText("No more script arguments to shift!\n", preset: "scripterror")
            return .exit
        }
        
        return .next
    }

    func handleUnvar(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .unvar(key) = token else {
            return .next
        }

        self.notify("deleting variable \(key)\n", debug:ScriptLogLevel.wait)
        self.variables.removeValue(forKey: key)

        return .next
    }

    func handleWait(_ token:TokenValue) -> ScriptExecuteResult {
        guard case .wait = token else {
            return .next
        }

        self.notify("wait for prompt\n", debug:ScriptLogLevel.wait)
        self.reactToStream.append(WaitforPromptOp())
        return .wait
    }

    func handleWaitfor(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .waitfor(text) = token else {
            return .next
        }

        self.notify("waitfor \(text)\n", debug:ScriptLogLevel.wait)
        self.reactToStream.append(WaitforOp(text))
        return .wait
    }

    func handleWaitforre(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .waitforre(pattern) = token else {
            return .next
        }

        self.notify("waitforre \(pattern)\n", debug:ScriptLogLevel.wait)
        self.reactToStream.append(WaitforReOp(pattern))
        return .wait
    }

    func handleVariable(_ token:TokenValue) -> ScriptExecuteResult {
        guard case let .variable(key, value) = token else {
            return .next
        }

        self.notify("setvariable \(key) \(value)\n", debug:ScriptLogLevel.vars)
        self.variables[key] = value

        return .next
    }
}


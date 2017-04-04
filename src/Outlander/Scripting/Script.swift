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

    private var reactToStream:[IWantStreamInfo]

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
    }

    func run(_ args:[String]) {

        self.started = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let formattedDate = dateFormatter.string(from: self.started!)

        self.sendText(String(format:"[Starting '\(self.fileName)' at \(formattedDate)]\n"))
        
        initialize(self.fileName, context: self.context)

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
                    sendText("script '\(fileName)' cannot include itself!\n", preset: "scripterror", fileName: fileName, scriptLine: index - 1)
                    continue
                }
                print("\(includeName)(\(index))")
                self.notify("including '\(includeName)'\n", debug: ScriptLogLevel.gosubs, scriptLine: index - 1)
                initialize(includeName, context: context)
            } else {
                let scriptLine = ScriptLine(originalText: line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), fileName: fileName, lineNumber: index, token: nil)
                context.lines.append(scriptLine)
            }

            if let label = labelRegex.firstMatch(line as NSString) {
                if let existing  = context.labels[label] {
                    sendText("replacing label '\(existing.name)' from '\(existing.fileName)'\n", preset: "scripterror", fileName: fileName, scriptLine: index - 1)
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

    func stop() {
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

        print(token)

        switch token {
            case .debug(let level):
                self.debugLevel = ScriptLogLevel(rawValue: level) ?? ScriptLogLevel.none
                self.notify("debuglevel \(self.debugLevel.rawValue)\n", debug:ScriptLogLevel.gosubs)
                return .next
            case .echo(let text):
                self.gameContext.events.echoText(text)
                return .next
            case .put(let text):
                return self.handlePut(text)
            case .send(let text):
                return self.handleSend(text)
            case .exit:
                self.notify("exit\n", debug:ScriptLogLevel.gosubs)
                return .exit
            case .goto(let label):
                return gotoLabel(label)
            case .label(let label):
                self.notify("passing label '\(label)'\n", debug:ScriptLogLevel.gosubs)
                return .next
            case .move(let dir):
                self.notify("move \(dir)\n", debug:ScriptLogLevel.wait)
                self.reactToStream.append(MoveOp())
                self.sendCommand("\(dir)")
                return .wait
            case .nextroom:
                self.notify("nextroom\n", debug:ScriptLogLevel.wait)
                self.reactToStream.append(NextRoomOp())
                return .wait
            case .pause(let time):
                self.notify("pausing for \(time) seconds\n", debug:ScriptLogLevel.wait)
                delay(time) {
                    self.next()
                }
                return .wait
            case .waitfor(let text):
                self.notify("waitfor \(text)\n", debug:ScriptLogLevel.wait)
                self.reactToStream.append(WaitforOp(text))
                return .wait
            case .waitforre(let pattern):
                self.notify("waitforre \(pattern)\n", debug:ScriptLogLevel.wait)
                self.reactToStream.append(WaitforReOp(pattern))
                return .wait
            default:
                return .next
        }
    }

    func gotoLabel(_ label:String) -> ScriptExecuteResult {

        guard let target = self.context.labels[label.lowercased()] else {
            self.notify("label '\(label)' not found", preset: "scripterror", debug:ScriptLogLevel.gosubs)
            return .exit
        }

//        let scriptLine = self.context.lines[target.line]

        self.notify("goto '\(label)'\n", debug:ScriptLogLevel.gosubs)
        self.context.currentLineNumber = target.line - 1

        return .next
    }

    func handlePut(_ text:String) -> ScriptExecuteResult {

        let cmds = text.splitToCommands()
        for cmd in cmds {
            self.sendCommand(cmd)
        }

        return .next
    }

    func handleSend(_ text:String) -> ScriptExecuteResult {
        self.sendCommand("#send \(text)")
        return .next
    }
}


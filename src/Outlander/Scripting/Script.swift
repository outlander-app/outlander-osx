//
//  Script.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

protocol IScript {
    var fileName:String { get }
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
}

class ScriptContext {
    var lines: [ScriptLine] = []
    var labels: [String:Label] = [:]
    var currentLineNumber:Int = -1

    var currentLine:ScriptLine? {
        get {
            if currentLineNumber >= lines.count {
                return nil
            }

            return lines[currentLineNumber]
        }
    }

    func advance() {
        currentLineNumber += 1
    }
}

class Script : IScript {
    let labelRegex: Regex
    let includeRegex: Regex

    let fileName: String
    let loader: (String) -> [String]
    let gameContext: GameContext
    let context: ScriptContext

    init(loader: @escaping ((String) -> [String]), _ fileName: String, _ gameContext:GameContext) throws {
        self.loader = loader
        self.fileName = fileName
        self.gameContext = gameContext
        self.context = ScriptContext()

        labelRegex = try Regex("^\\s*(\\w+((\\.|-|\\w)+)?):")
        includeRegex = try Regex("^\\s*include (.+)$")
    }

    func run(_ args:[String]) {
        initialize(self.fileName, context: self.context)

        next()
    }

    fileprivate func initialize(_ fileName: String, context: ScriptContext) {
        let lines = self.loader(fileName)

        print("line count: \(lines.count)")

        var index = 0

        for line in lines {
            index += 1

            if line == "" {
                continue
            }

            if let include = includeRegex.firstMatch(line as NSString) {
                guard include != fileName else {
                    print("script \(fileName) cannot include itself!")
                    continue
                }
                print("\(include)(\(index))")
                initialize(include, context: context)
            } else {
                let scriptLine = ScriptLine(originalText: line, fileName: fileName, lineNumber: index)
                context.lines.append(scriptLine)
            }

            if let label = labelRegex.firstMatch(line as NSString) {
                if let existing  = context.labels[label] {
                    print("*** \(fileName)(\(index)): replacing label \(existing.name) ***")
                }
                context.labels[label] = Label(name: label, line: context.lines.count - 1, fileName: fileName)
            }
        }
    }

    func next() {
        self.context.advance()

        guard let line = self.context.currentLine  else {
            return
        }

        self.gameContext.events.echoText(line.originalText)

        next()
    }

    func gotoLabel(_ label:String) -> ScriptLine? {
        guard let target = self.context.labels[label] else {
            // throw error that label wasn't found
            return nil
        }

        let scriptLine = self.context.lines[target.line]
        print("Found: \(scriptLine.fileName)(\(scriptLine.lineNumber)) \(scriptLine.originalText)")
        return scriptLine
    }
}


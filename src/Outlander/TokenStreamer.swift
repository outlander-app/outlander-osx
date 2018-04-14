//
//  TokenStreamer.swift
//  Outlander
//
//  Created by Joseph McBride on 6/2/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class Component {
}

struct StreamVariable {
    var key:String
    var value:String
}

class TokenStreamer {
    private var inSetup = true
    
    private var mono = false
    private var bold = false
   
    private var lastStreamId = ""
    private var inStream = false

    private var lastStyleId = ""

    private var lastToken:StreamToken?
    private var lastPrompt:String?

    private var lastDequedTag:TextTag?
    private var needNewlineAfterPrompt = false

    public var textTags:Queue<TextTag> = Queue<TextTag>()

    public var text:(([TextTag])->())
    public var variable:((StreamVariable)->())
    public var clearStream:((String)->())
    public var roundtime:((Roundtime)->())
    public var spell:((String)->())
    public var vitals:((Vitals)->())

    private let dirMap = [
        "n": "north",
        "s": "south",
        "e": "east",
        "w": "west",
        "ne": "northeast",
        "nw": "northwest",
        "se": "southeast",
        "sw": "southwest",
        "up": "up",
        "down": "down",
        "out": "out"
    ]

    private let roomTags = [
        "roomdesc",
        "roomobjs",
        "roomplayers",
        "roomexits"
    ]

    class func newInstance() -> TokenStreamer {
        return TokenStreamer()
    }

    init() {
        self.text = { _ in }
        self.variable = { _ in }
        self.clearStream = { _ in }
        self.roundtime = { _ in }
        self.spell = { _ in }
        self.vitals = { _ in }
    }

    public func stream(_ tokens:[StreamToken]) {
        processTokens(tokens)
    }

    public func run() {
        let timer = Timer(timeInterval: 0.5, target: self, selector: #selector(self.tick), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }

    @objc
    func tick(timer:Timer) {
        print("tokenStreamer")
    }

    private func processTokens(_ tokens:[StreamToken]) {
        var hasText = false

        for token in tokens {
            switch token {
            case .text(let text):
                handleText(text)
                hasText = true
                break
            case .tag(let name, let attrs, let children): handleTag(token, name, attrs, children)
            }

            self.lastToken = token
        }

        if hasText {
            handleText("\n")
        }
    }

    private func handleText(_ text:String) {

        let tag = tagFor(text)
        tag.targetWindow = lastStreamId

        if lastStyleId.lowercased() == "roomname" {
            tag.preset = "roomname"
        }

        if lastStreamId.characters.count == 0 && self.needNewlineAfterPrompt {
            tag.text = "\n\(tag.text!)"
            self.needNewlineAfterPrompt = false
        }

        self.textTags.enqueue(tag)
    }

    private func handleTag(_ token:StreamToken, _ name:String, _ attributes:[Attribute], _ children:[StreamToken]) {

        switch name.lowercased() {

        case "a":
            let value = valueFor(children)
            let tag = tagFor(value)
            tag.href = token.attr("href") ?? ""
            self.enqueue(tag)
            break

        case "app":
            emitVariable("charactername", token.attr("char") ?? "")
            emitVariable("game", token.attr("game") ?? "")
            break

        case "b":
            let value = valueFor(children)
            let tag = tagFor(value)
            if inStream {
                tag.bold = true
                tag.targetWindow = lastStreamId
            }
            self.enqueue(tag)
            break

        case "d":
            let value = valueFor(children)
            let tag = tagFor(value)

            if let cmd = token.attr("command") {
                tag.command = cmd
            }
            
            self.enqueue(tag)
            break

        case "clearstream":
            if let window = token.attr("id") {
                self.clearStream(window.lowercased())
            }
            break

        case "compass":
            let dirs = children.filter { $0.name() == "dir" && $0.attr("value") != nil }

            var found:[String] = []
            
            for dir in dirs {
                if let mapped = self.dirMap[dir.attr("value")!] {
                    found.append(mapped)
                    emitVariable(mapped, "1")
                }
            }
            
            let notFound = self.dirMap.values.filter { !found.contains($0) }
            
            for dir in notFound {
                emitVariable(dir, "0")
            }
            
            break

        case "dialogdata":
            guard token.attr("id") == "minivitals" else {
                break
            }

            let vitals = children.filter {$0.name()?.lowercased() == "progressbar" && $0.hasAttr("id")}

            for vital in vitals {
                let name = vital.attr("id") ?? ""
                let value = vital.attr("value") ?? "0"
                emitVariable(name, value)

                let send = Vitals(name, value: UInt16(Int(value)!))
                self.vitals(send!)
            }
            break

        case "endsetup":
            self.inSetup = false
            break

        case "indicator":
            let id = token.attr("id")?.substringFromIndex(4).lowercased() ?? ""
            let visible = token.attr("visible") == "y" ? "1" : "0"
            
            if id.characters.count == 0 {
                return
            }
            
            emitVariable(id, visible)
            break

        case "left", "right":
            let value = valueFor(children)
            emitVariable("\(name.lowercased())hand", value)
            emitVariable("\(name.lowercased())handnoun", token.attr("noun") ?? "")
            break

        case "output":
            if token.attr("class") == "mono" {
                self.mono = true
            } else {
                self.mono = false
            }
            break

        case "preset":
            let value = valueFor(children)
            let presetId = token.attr("id") ?? ""
            let tag = tagFor("\(value)", presetId.lowercased())
            tag.targetWindow = lastStreamId
            self.enqueue(tag)
            break
            
        case "prompt":
            var value = valueFor(children)
            value = value.replace("&gt;", withString: ">")

            emitVariable("prompt", value)
            emitVariable("gametime", token.attr("time") ?? "")

            let today = Date().timeIntervalSince1970
            emitVariable("gametimeupdate", "\(today)")

            if value != lastPrompt || !self.textTags.isEmpty {
                let tag = tagFor("\(value)")
                self.enqueue(tag, true)
            }

            self.lastPrompt = value

            self.dequeue()
            break

        case "pushbold":
            self.bold = true
            break

        case "pushstream":
            lastStreamId = token.attr("id")?.lowercased() ?? ""
            inStream = true
            break

        case "popbold":
            self.bold = false
            break

        case "popstream":
            lastStreamId = ""
            inStream = false
            break

        case "roundtime":
            if let val = token.attr("value") {
                if let time = Int(val) {
                    let rt = Roundtime()
                    rt.time = Date(timeIntervalSince1970: TimeInterval(time))
                    self.roundtime(rt)
                }
            }
            break

        case "spell":
            let spell = valueFor(children)
            emitVariable("preparedspell", spell)
            self.spell(spell)
            break

        case "style":
            lastStyleId = token.attr("id") ?? ""
            break
            
        default:
            break
        }
    }

    private func emitVariable(_ key:String, _ value:String) {
        self.variable(StreamVariable(key: key, value: value))
    }

    private func enqueue(_ tag:TextTag, _ prompt:Bool = false) {
        if inSetup {
            self.text([tag])
        } else {
            self.textTags.enqueue(tag)
        }

        self.needNewlineAfterPrompt = prompt
    }

    private func dequeue() {
        let tags = self.dequeueTags()

        self.lastDequedTag = tags.last
        
        self.text(tags)
    }

    private func dequeueTags() -> [TextTag] {
        var tags:[TextTag] = []

        var tag:TextTag?

        repeat {
            tag = self.textTags.dequeue()
            if let t = tag {
                tags.append(t)
            }
        } while tag != nil

        return tags
    }

    private func tagFor(_ text:String, _ preset:String = "") -> TextTag {
        let tag = TextTag(text, mono: self.mono)!
        tag.bold = self.bold
        tag.preset = preset
        return tag
    }

    private func valueFor(_ children:[StreamToken]) -> String {
        return children.flatMap({$0.value()}).joined(separator: ",")
    }
}

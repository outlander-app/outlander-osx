//
//  StormFrontTagStreamer.swift
//  Outlander
//
//  Created by Joseph McBride on 3/21/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
open class StormFrontTagStreamer : NSObject {
    
    fileprivate var tags:[TextTag]
    fileprivate var lastNode:Node?
    
    fileprivate var mono = false
    fileprivate var bold = false
   
    fileprivate var lastStreamId = ""
    fileprivate var inStream = false
    fileprivate var ignoreNextEot = false
    
    fileprivate let ignoredEot = [
        "app",
        "clearstream",
        "compass",
        "compdef",
        "component",
        "dialogdata",
        "endsetup",
        "exposecontainer",
        "indicator",
        "left",
        "mode",
        "opendialog",
        "nav",
        "output",
        "right",
        "streamwindow",
        "spell",
        "switchquickbar"
    ]
    
    fileprivate let ignoreNextEotList = [
        "experience",
        "inv",
        "popstream",
        "room"
    ]
    
    fileprivate let roomTags = [
        "roomdesc",
        "roomobjs",
        "roomplayers",
        "roomexits"
    ]
    
    fileprivate let dirMap = [
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
    
    open var isSetup = true
    open var emitSetting : ((String,String)->Void)?
    open var emitExp : ((SkillExp)->Void)?
    open var emitRoundtime : ((Roundtime)->Void)?
    open var emitRoom : (()->Void)?
    open var emitProcessNode : ((Node)->Void)?
    open var emitSpell : ((String)->Void)?
    open var emitVitals : ((Vitals)->Void)?
    open var emitWindow : ((String,String?,String?)->Void)?
    open var emitClearStream : ((String)->Void)?
    
    class func newInstance() -> StormFrontTagStreamer {
        return StormFrontTagStreamer()
    }
    
    override init() {
        tags = []
    }
    
    open func stream(_ nodes:[Node]) -> [TextTag] {
        let tags:[TextTag] = nodes
            .map { (node) -> TextTag? in
                self.processNode(node)
                
                self.emitProcessNode?(node)
                
                return self.tagForNode(node)
            }
            .filter { $0 != nil }
            .map { $0! }
        
        if inStream && tags.count > 0 {
            let tag = tags.last!
            tag.text = "\(tag.text!)\n"
        }
        
        return tags
        
//        var newTags = [TextTag]
//        
//        var tag = TextTag()
//        tag.text = ""
//        
//        for t in tags {
//            tag.text = tag.text + t.text
//            tag.color = t.color ?? tag.color
//            tag.backgroundColor = t.backgroundColor ?? tag.backgroundColor
//            tag.mono = tag.mono || t.mono
//            tag.bold = tag.bold || t.bold
//            tag.targetWindow = t.targetWindow ?? tag.targetWindow
//        }
//        
//        return [tag]
    }
    
    open func streamSingle(_ node:Node) -> Array<TextTag> {
        return stream([node])
    }
    
    open func processNode(_ node:Node) {
        if emitSetting == nil {
            return
        }
        
        switch node.name {
            
            
        case _ where node.name == "prompt":
            emitSetting?("prompt", node.value?.replace("&gt;", withString: ">") ?? "")
            emitSetting?("gametime", node.attr("time") ?? "")
            
            let today = Date().timeIntervalSince1970
            emitSetting?("gametimeupdate", "\(today)")
            
        case _ where node.name == "roundtime":
            let roundtime = Roundtime()
            roundtime.time = Date(timeIntervalSince1970: TimeInterval(Int(node.attr("value")!)!))
            emitRoundtime?(roundtime)
            
        case _ where node.name == "component":
            var compId = node.attr("id")?.replace(" ", withString: "_") ?? ""
            
            if !compId.hasPrefix("exp") {
                compId = compId.replace("_", withString: "")
                
                var value = node.value ?? ""
                
                if compId == "roomexits" {
                    if node.children.count > 0 {
                        value = nodeChildValues(node)
                    }
                }
                
                if compId == "roomobjs" {
                    var origValues = value
                    var monsters = ""
                    var monsterCount = 0
                    if node.children.count > 0 {
                        value = nodeChildValues(node)
                        let bolds = nodeChildValuesWithBold(node)
                        origValues = bolds.0
                        monsters = bolds.1
                        monsterCount = bolds.2
                    }
                    
                    emitSetting?("roomobjsorig", origValues)
                    emitSetting?("monsterlist", monsters)
                    emitSetting?("monstercount", "\(monsterCount)")
                }
                
                emitSetting?(compId, value)
                
                if roomTags.contains(compId) {
                    emitRoom?()
                }
                
            } else if !compId.hasPrefix("exp_tdp") {
                var val = ""
                var isNew = false
                var isBrief = false
                
                if(node.children.count > 0
                    && node.children[0].name == "preset"
                    && node.children[0].attr("id") == "whisper") {
                    isNew = true
                }
                
                if node.children.count > 0 && (node.children.count == 2 || node.children[0].children.count > 1) {
                    isBrief = true
                }
               
                if isBrief {
                    
                    if isNew {
                        val = nodeChildValues(node.children[0])
                    } else {
                        val = nodeChildValues(node)
                    }
                    
                    parseExpBrief(compId, data: val, isNew: isNew)
                } else {
                    
                    if isNew {
                        val = node.children[0].value ?? ""
                    } else {
                        val = node.value ?? ""
                    }
                    
                    parseExp(compId, data: val, isNew: isNew)
                }
            }
            
        case _ where node.name == "left" || node.name == "right":
            emitSetting?("\(node.name)hand", node.value ?? "Empty")
            emitSetting?("\(node.name)handnoun", node.attr("noun") ?? "")
            
        case _ where node.name == "spell":
            if let spell = node.value {
                emitSetting?("preparedspell", spell)
                emitSpell?(spell)
            }
            
        case _ where node.name == "indicator":
            let id = node.attr("id")?.substringFromIndex(4).lowercased() ?? ""
            let visible = node.attr("visible") == "y" ? "1" : "0"
            
            if id.characters.count == 0 {
                return
            }
            
            emitSetting?(id, visible)
            
        case _ where node.name == "compass":
            let dirs = node.children
                .filter { $0.name == "dir" && $0.hasAttr("value") }
            
            var found:[String] = []
            
            for dir in dirs {
                let mapped = self.dirMap[dir.attr("value")!]!
                found.append(mapped)
                emitSetting?(mapped, "1")
            }
            
            let notFound = dirMap.values.filter { !found.contains($0) }
            
            for dir in notFound {
                emitSetting?(dir, "0")
            }
            
        case _ where node.name == "streamwindow":
            let id = node.attr("id")
            var subtitle = node.attr("subtitle")
            if id == "main" && subtitle != nil && subtitle!.characters.count > 3 {
                subtitle = subtitle!.substring(from: subtitle!.characters.index(subtitle!.startIndex, offsetBy: 3))
                if let t = subtitle {
                    emitSetting?("roomtitle", t)
                }
            }
            
            if let win = id {
                emitWindow?(win.lowercased(), node.attr("title"), node.attr("ifClosed"))
            }
        
        case _ where node.name == "clearstream":
            if let id = node.attr("id") {
                emitClearStream?(id.lowercased())
            }
            
        case _ where node.name == "dialogdata" && node.attr("id") == "minivitals":
            let vitals = node.children
                            .filter {$0.name == "progressbar" && $0.hasAttr("id")}
            
            for vital in vitals {
                let name = vital.attr("id")!
                let value = vital.attr("value") ?? "0"
                emitSetting?(name, value)
               
                let send = Vitals(name, value: UInt16(Int(value)!))
                emitVitals?(send!)
            }
            
        case _ where node.name == "app":
            emitSetting?("charactername", node.attr("char") ?? "")
            emitSetting?("game", node.attr("game") ?? "")
            
        default:
            // do nothing
            return
        }
    }
    
    open func tagForNode(_ node:Node) -> TextTag? {
        var tag:TextTag? = nil
        
        switch node.name {
            
        case _ where node.name == "text":
            
            tag = emitTag(node)
            tag?.targetWindow = lastStreamId
            if inStream {
                if lastStreamId == "logons" || lastStreamId == "death" {
                    tag?.text = tag?.text.trimmingCharacters(in: CharacterSet.whitespaces)
                }
            }
           
            if lastNode?.name == "preset" && tag!.text.characters.count > 0 && tag!.text!.hasPrefix("  You also see") {
                let text = tag!.text!.trimPrefix("  ")
                tag?.text = "\n\(text)"
                tag?.preset = lastNode?.attr("id")
            }
            
            // room name
            if lastNode?.name == "style" && lastNode?.attr("id") == "roomName" {
//                tag?.color = "#0000FF"
                tag?.preset = "roomname"
            }

        case _ where node.name == "eot":
            if inStream
                || lastNode != nil && (ignoredEot.contains(lastNode!.name)
                || lastNode!.name == "prompt") {
                break
            }
            if ignoreNextEot {
                ignoreNextEot = false
                break
            }
            tag = TextTag()
            tag?.text = "\r\n"
            
        case _ where node.name == "prompt":
            if lastNode != nil && lastNode!.name == "popstream" {
                break
            }
            tag = emitTag(node)
            tag?.text = tag!.text! + "\r\n"
            
        case _ where node.name == "preset":
            tag = emitTag(node)
            tag?.targetWindow = lastStreamId
            let id = node.attr("id")
            tag?.preset = id
//            if id == "speech" || id == "whisper" || id == "whispers" || id == "thought" || id == "chatter" {
//                tag?.color = "#99FFFF"
//            }

        case _ where node.name == "pushbold":
            self.bold = true
            
        case _ where node.name == "popbold":
            self.bold = false
            
        case _ where node.name == "pushstream":
            inStream = true
            if let id = node.attr("id") {
                lastStreamId = id.lowercased()
            }
            
        case _ where node.name == "popstream":
            ignoreNextEot = ignoreNextEotList.contains(lastStreamId)
            inStream = false
            lastStreamId = ""
            
        case _ where node.name == "output":
            if let style = node.attr("class") {
                if style == "mono" {
                    self.mono = true
                } else {
                    self.mono = false
                }
            }
            
        case _ where node.name == "a":
            tag = emitTag(node)
            tag?.href = node.attr("href")
            
        case _ where node.name == "b":
            
            tag = emitTag(node)
            
            // <b>You yell,</b> Hogs!
            if inStream {
                tag?.bold = true
                tag?.targetWindow = lastStreamId
            }
            
        case _ where node.name == "d":
            
            if node.children.count > 0 {
                
                if node.children[0].name == "b" {
                    tag = emitTag(node.children[0])
                }
                
            } else {
                tag = emitTag(node)
            }
            
            if let cmd = node.attr("cmd") {
                tag?.command = cmd
            }
            
        case _ where node.name == "dynastream":
            if node.children.count > 0 {
                tag = emitTag(node)
                tag?.text = self.nodeChildValues(node)
            } else {
                tag = emitTag(node)
            }
            
        default:
           tag = nil
        }
       
        self.lastNode = node
        return tag
    }
    
    open func nodeChildValuesRecursive(_ node:Node) -> String {
        
        var result = ""
       
        for child in node.children {
            if child.name == "text" || child.name == "d" {
                result += child.value ?? ""
            }
            
            result += nodeChildValuesRecursive(child)
        }
        
        return result
    }
    
    open func nodeChildValues(_ node:Node) -> String {
        
        var result = ""
       
        for child in node.children {
            if child.name == "text" || child.name == "d" {
                result += child.value ?? ""
            }
        }
        
        return result
    }

    open func nodeChildValuesWithBold(_ node:Node) -> (String, String, Int) {
        
        var result = ""
        var monsters = ""
        var monsterCount = 0
        var lastNode:Node?
       
        for child in node.children {
            if child.name == "text" || child.name == "d" {
                result += child.value ?? ""
            }
            
            if child.name == "pushbold" {
                result += "<pushbold/>"
            }
            
            if child.name == "popbold" {
                monsterCount += 1
                if monsters.characters.count > 0 {
                    monsters += "|"
                }
                monsters += lastNode?.value ?? ""
                result += "<popbold/>"
            }
            
            lastNode = child
        }
        
        return (result, monsters, monsterCount)
    }
    
    open func parseExpBrief(_ compId:String, data:String, isNew:Bool) {
        let expName = compId.substring(from: compId.characters.index(compId.startIndex, offsetBy: 4))
        
        if data.characters.count == 0 {
            
            let rate = LearningRate.fromRate(0)
            let skill = SkillExp()
            skill.name = expName
            skill.ranks = NSDecimalNumber(value: 0.0 as Double)
            skill.mindState = rate
            skill.isNew = isNew
            
            emitSetting?("\(expName).LearningRate", "\(rate.rateId)")
            emitSetting?("\(expName).LearningRateName", "\(rate.desc)")
            
            emitExp?(skill)
            return
        }
        
        let pattern = ".+:\\s+(\\d+)\\s(\\d+)%\\s+\\[\\s?(\\d+)?.*";
        
        let trimmed = data.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      
        let ranks = trimmed.mutable
        ranks[pattern] ~= "$1.$2"
        
        let mindstate = trimmed.mutable
        mindstate[pattern] ~= "$3"
        
        let mindstateNumber = NSDecimalNumber(string: mindstate as String)
        
        let rate = LearningRate.fromRate(mindstateNumber.uint16Value)
        
        let skill = SkillExp()
        skill.name = expName
        skill.ranks = NSDecimalNumber(string:ranks as String)
        skill.mindState = rate
        skill.isNew = isNew
        
        emitSetting?("\(expName).Ranks", ranks as String)
        emitSetting?("\(expName).LearningRate", "\(rate.rateId)")
        emitSetting?("\(expName).LearningRateName", "\(rate.desc)")
        
        emitExp?(skill)
    }
    
    open func parseExp(_ compId:String, data:String, isNew:Bool) {
        
        let expName = compId.substring(from: compId.characters.index(compId.startIndex, offsetBy: 4))
        
        if data.characters.count == 0 {
            
            let rate = LearningRate.fromRate(0)
            let skill = SkillExp()
            skill.name = expName
            skill.ranks = NSDecimalNumber(value: 0.0 as Double)
            skill.mindState = rate
            skill.isNew = isNew
            
            emitSetting?("\(expName).LearningRate", "\(rate.rateId)")
            emitSetting?("\(expName).LearningRateName", "\(rate.desc)")
            
            emitExp?(skill)
            return
        }
        
        let pattern = ".+:\\s+(\\d+)\\s(\\d+)%\\s(\\w.*)?.*";
        
        let trimmed = data.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      
        let ranks = trimmed.mutable
        ranks[pattern] ~= "$1.$2"
        
        let mindstate = trimmed.mutable
        mindstate[pattern] ~= "$3"
        
        var rate = LearningRate.fromDescription(mindstate as String)

        if rate == nil {
            rate = LearningRate.fromRate(0)
        }
        
        let skill = SkillExp()
        skill.name = expName
        skill.ranks = NSDecimalNumber(string:ranks as String)
        skill.mindState = rate!
        skill.isNew = isNew
        
        emitSetting?("\(expName).Ranks", ranks as String)
        emitSetting?("\(expName).LearningRate", "\(rate!.rateId)")
        emitSetting?("\(expName).LearningRateName", "\(rate!.desc)")
        
        emitExp?(skill)
    }
    
    func emitTag(_ node:Node) -> TextTag? {
        let tag:TextTag? = TextTag()
        var text = node.value?.replace("&gt;", withString: ">")
        text = text?.replace("&lt;", withString: "<")
        tag?.text = text
        tag?.bold = self.bold
        tag?.mono = self.mono
        return tag
    }
}

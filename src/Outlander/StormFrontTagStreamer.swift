//
//  StormFrontTagStreamer.swift
//  Outlander
//
//  Created by Joseph McBride on 3/21/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public class StormFrontTagStreamer {
    
    private var tags:[TextTag]
    private var lastNode:Node?
    
    private var mono = false
    private var bold = false
   
    private var lastStreamId = ""
    private var inStream = false
    
    private let ignoredEot = [
        "app",
        "clearstream",
        "compass",
        "compdef",
        "component",
        "dialogdata",
        "indicator",
        "left",
        "mode",
        "nav",
        "output",
        "popstream",
        "pushstream",
        "right",
        "streamwindow",
        "spell",
        "switchquickbar"
    ]
    
    private let roomTags = [
        "roomdesc",
        "roomobjs",
        "roomplayers",
        "roomexits"
    ]
    
    public var isSetup = true
    public var emitSetting : ((String,String)->Void)?
    public var emitExp : ((SkillExp)->Void)?
    public var emitRoundtime : ((Roundtime)->Void)?
    public var emitRoom : (()->Void)?
    public var emitProcessNode : ((Node)->Void)?
    public var emitSpell : ((String)->Void)?
    public var emitVitals : ((Vitals)->Void)?
    
    class func newInstance() -> StormFrontTagStreamer {
        return StormFrontTagStreamer()
    }
    
    init() {
        tags = []
    }
    
    public func stream(nodes:[Node]) -> [TextTag] {
        var tags:[TextTag] = nodes
            .map {
                self.processNode($0)
                
                self.emitProcessNode?($0)
                
                return self.tagForNode($0)
            }
            .filter { $0 != nil }
            .map { $0! }
        
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
    
    public func streamSingle(node:Node) -> Array<TextTag> {
        return stream([node])
    }
    
    public func processNode(node:Node) {
        if emitSetting == nil {
            return
        }
        
        switch node.name {
            
        case _ where node.name == "app":
            emitSetting?("charactername", node.attr("char") ?? "")
            emitSetting?("game", node.attr("game") ?? "")
            
        case _ where node.name == "prompt":
            emitSetting?("prompt", node.value?.replace("&gt;", withString: ">") ?? "")
            emitSetting?("gametime", node.attr("time") ?? "")
            
            let today = NSDate().timeIntervalSince1970
            emitSetting?("gametimeupdate", "\(today)")
            
        case _ where node.name == "roundtime":
            var roundtime = Roundtime()
            roundtime.time = NSDate(timeIntervalSince1970: NSTimeInterval(node.attr("value")!.toInt()!))
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
                    if node.children.count > 0 {
                        value = nodeChildValues(node)
                        origValues = nodeChildValuesWithBold(node)
                    }
                    
                    emitSetting?("roomobjsorig", origValues)
                }
                
                emitSetting?(compId, value)
                
                if contains(roomTags, compId) {
                    emitRoom?()
                }
                
            } else if !compId.hasPrefix("exp_tdp") {
                if let val = node.children.count > 0 ? node.children[0].value : node.value {
                    parseExp(compId, data: val, isNew: node.children.count > 0)
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
            
        case _ where node.name == "streamwindow":
            var id = node.attr("id")
            var subtitle = node.attr("subtitle")
            if id == "main" && subtitle != nil && count(subtitle!) > 3 {
                subtitle = subtitle!.substringFromIndex(advance(subtitle!.startIndex, 3))
                if let t = subtitle {
                    emitSetting?("roomtitle", t)
                }
            }
            
        case _ where node.name == "dialogdata" && node.attr("id") == "minivitals":
            let vitals = node.children
                            .filter {$0.name == "progressbar" && $0.hasAttr("id")}
            
            for vital in vitals {
                let name = vital.attr("id")!
                let value = vital.attr("value") ?? "0"
                emitSetting?(name, value)
               
                let send = Vitals(with: name, value: UInt16(value.toInt()!))
                emitVitals?(send)
            }
            
        default:
            // do nothing
            return
        }
    }
    
    public func tagForNode(node:Node) -> TextTag? {
        var tag:TextTag? = nil
        
        if !isSetup {
            isSetup = node.name == "endsetup"
            return nil
        }
        
        switch node.name {
            
        case _ where node.name == "app":
            isSetup = false
            
        case _ where node.name == "text":
            if inStream && (lastStreamId == "inv" || lastStreamId == "talk" || lastStreamId == "whispers" || lastStreamId == "ooc") {
                break
            }
            
            tag = emitTag(node)
            tag?.targetWindow = self.streamIdToWindow(lastStreamId)
            if inStream {
                tag?.text = "\(tag!.text!)\n"
                if lastStreamId == "logons" || lastStreamId == "death" {
                    tag?.text = tag?.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                }
            }
           
            if lastNode?.name == "preset" && count(tag!.text) > 0 && tag!.text!.hasPrefix("  You also see") {
                var text = tag!.text!.trimPrefix("  ")
                tag?.text = "\n\(text)"
            }
            
            // room name
            if lastNode?.name == "style" && lastNode?.attr("id") == "roomName" {
                tag?.color = "#0000FF"
            }
            
        case _ where node.name == "eot":
            if inStream || lastNode != nil && (contains(ignoredEot, lastNode!.name) || lastNode!.name == "prompt") {
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
            if inStream && (lastStreamId == "talk" || lastStreamId == "whispers" || lastStreamId == "ooc") {
                break
            }
            tag = emitTag(node)
            tag?.targetWindow = self.streamIdToWindow(lastStreamId)
            let id = node.attr("id")
            tag?.preset = id
            if id == "speech" || id == "whisper" || id == "thought" {
                tag?.color = "#99FFFF"
            }
            
        case _ where node.name == "pushbold":
            self.bold = true
            
        case _ where node.name == "popbold":
            self.bold = false
            
        case _ where node.name == "pushstream":
            inStream = true
            if let id = node.attr("id") {
                lastStreamId = id
            }
            
        case _ where node.name == "popstream":
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
            // <b>You yell,</b> Hogs!
            if inStream && lastStreamId == "talk" {
                break
            }
            tag = emitTag(node)
            
        case _ where node.name == "d":
            tag = emitTag(node)
            if let cmd = node.attr("cmd") {
                tag?.command = cmd
            }
            
        default:
           tag = nil
        }
       
        self.lastNode = node
        return tag
    }
    
    public func streamIdToWindow(streamId:String) -> String {
        switch(streamId) {
        case _ where streamId == "logons":
            return "arrivals"
        case _ where streamId == "thoughts" || streamId == "chatter":
            return "thoughts"
        case _ where streamId == "death":
            return "deaths"
        case _ where streamId == "whispers":
            return "whispers"
        case _ where streamId == "ooc":
            return "ooc"
        default:
            return "main"
        }
    }
    
    public func nodeChildValues(node:Node) -> String {
        
        var result = ""
       
        for child in node.children {
            if child.name == "text" || child.name == "d" {
                result += child.value ?? ""
            }
        }
        
        return result
    }

    public func nodeChildValuesWithBold(node:Node) -> String {
        
        var result = ""
       
        for child in node.children {
            if child.name == "text" || child.name == "d" {
                result += child.value ?? ""
            }
            
            if child.name == "pushbold" {
                result += "<pushbold/>"
            }
            
            if child.name == "popbold" {
                result += "<popbold/>"
            }
        }
        
        return result
    }
    
    public func parseExp(compId:String, data:String, isNew:Bool) {
        
        if count(data) == 0 {
            return
        }
        
        let pattern = ".+:\\s+(\\d+)\\s(\\d+)%\\s(\\w.*)?.*";
        
        var trimmed = data.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
      
        var ranks = RegexMutable(trimmed)
        ranks[pattern] ~= "$1.$2"
        
        var mindstate = RegexMutable(trimmed)
        mindstate[pattern] ~= "$3"
        
        let rate = LearningRate.fromDescription(mindstate as String)
        let expName = compId.substringFromIndex(advance(compId.startIndex, 4))
        
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
    
    func emitTag(node:Node) -> TextTag? {
        let tag:TextTag? = TextTag()
        var text = node.value?.replace("&gt;", withString: ">")
        text = text?.replace("&lt;", withString: "<")
        tag?.text = text
        tag?.bold = self.bold
        tag?.mono = self.mono
        return tag
    }
}
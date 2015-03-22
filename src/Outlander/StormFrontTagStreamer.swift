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
    
    public var isSetup = true
    public var emitSetting : ((String,String)->Void)?
    
    class func newInstance() -> StormFrontTagStreamer {
        return StormFrontTagStreamer()
    }
    
    init() {
        tags = []
    }
    
    public func stream(nodes:Array<Node>) -> Array<TextTag> {
        return nodes
            .map {
                self.processNode($0)
                return self.tagForNode($0)
            }
            .filter { $0 != nil }
            .map { $0! }
    }
    
    public func streamSingle(node:Node) -> Array<TextTag> {
        return stream([node])
    }
    
    public func processNode(node:Node) {
        if emitSetting == nil {
            return
        }
        
        switch node.name {
            
        case _ where node.name == "prompt":
            emitSetting?("prompt", node.value?.replace("&gt;", withString: ">") ?? "")
            emitSetting?("gametime", node.attr("time") ?? "")
            
        default:
            // do nothing
            if 1 > 2 {}
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
            if inStream && (lastStreamId == "inv" || lastStreamId == "talk") {
                break
            }
            
            tag = emitTag(node)
            tag?.targetWindow = self.streamIdToWindow(lastStreamId)
            if inStream {
                tag?.text = "\(tag!.text!)\n"
            }
            
            if lastNode?.name == "preset" && countElements(tag!.text) > 0 && tag!.text!.hasPrefix("  You also see") {
                var text = tag!.text!.trimPrefix("  ")
                tag?.text = "\n\(text)"
            }
            
        case _ where node.name == "eot":
            if inStream || lastNode != nil && contains(ignoredEot, lastNode!.name) {
                break
            }
            tag = TextTag()
            tag?.text = "\n"
            
        case _ where node.name == "prompt":
            tag = emitTag(node)
            
        case _ where node.name == "preset":
            if inStream && lastStreamId == "talk" {
                break
            }
            tag = emitTag(node)
            tag?.targetWindow = self.streamIdToWindow(lastStreamId)
            //let id = node.attr("id")
            
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
        default:
            return "main"
        }
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
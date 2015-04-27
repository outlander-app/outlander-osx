//
//  ScriptRunner.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public class ScriptRunner : ISubscriber {
    
    class func newInstance(context:GameContext, notifier:INotifyMessage) -> ScriptRunner {
        return ScriptRunner(context: context, notifier: notifier)
    }
    
    var thread:Thread
    var notifier:INotifyMessage
    var context:GameContext
    var scriptLoader:ScriptLoader
    
    init(context:GameContext, notifier:INotifyMessage) {
        
        self.context = context
        self.thread = Thread(notifier)
        self.notifier = notifier
        self.scriptLoader = ScriptLoader(with: self.context, and: LocalFileSystem())
        
        context.events.subscribe(self, token: "startscript")
        context.events.subscribe(self, token: "script")
        context.events.subscribe(self, token: "ol:game-parse")
        context.events.subscribe(self, token: "ol:game-stream")
        
        self.context.globalVars.changed.subscribeNext { (obj:AnyObject?) -> Void in
            
            if let changed = obj as? Dictionary<String, String> {
                self.notifyVars(changed)
            }
        }
    }
    
    public func handle(token:String, data:[String:AnyObject]) {
        if token == "ol:game-stream" {
            self.stream(data)
        } else if token == "ol:game-parse" {
            self.parse(data)
        } else if token == "startscript" {
            self.start(data)
        } else if token == "script" {
            self.manage(data)
        }
    }
    
    func start(dict:[String:AnyObject]) {
        
        var scriptName = dict["target"] as! String
        var tokens = dict["args"] as? NSArray;
        
        self.abort(scriptName)
       
        self.loadAsync(scriptName, tokens: tokens)
    }
    
    func loadAsync(scriptName:String, tokens:NSArray?) {
        { () -> NSDate in
            var date = NSDate()
            
            if let scriptText = self.scriptLoader.load(scriptName) {
                
                var params = self.argsToParams(tokens)
                
                var script = Script(scriptName, self.notifier, self.thread)
                
                self.thread.addOperation(script)
                
                script.run(scriptText, globalVars: { () -> [String:String] in
                    return self.context.globalVars.copyValues() as! [String:String]
                }, params: params)
            }
            
            return date
        } ~> { (start) -> () in
            
            let diff = NSDate().timeIntervalSinceDate(start)
            
            println("\(scriptName) loaded in \(diff)")
        }
    }
    
    func argsToParams(args:NSArray?) -> [String] {
        if let input = args {
            var params:[String] = []
            
            for item in input {
                params.append(item as! String)
            }
            
            return params
        }
        
        return []
    }
    
    func stream(dict:[String:AnyObject]) {
        var nodes = dict["nodes"] as! [Node]
        var text = dict["text"] as! String
        
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? IScript {
                script.stream(text, nodes: nodes)
            }
        }
    }
    
    func parse(userInfo:[String:AnyObject]) {
        if let dict = userInfo as? [String:String] {
            var text = dict["text"] ?? ""
            
            for (index, q) in enumerate(self.thread.queue.operations) {
                if let script = q as? IScript {
                    script.stream(text, nodes: [])
                }
            }
        }
    }
    
    func manage(userInfo:[String:AnyObject]) {
        if let dict = userInfo as? [String:String] {
            var scriptName = dict["target"]!
            var action = dict["action"]!
            
            if action == "abort" {
                self.abort(scriptName)
            }
            else if action == "pause" {
                self.pause(scriptName)
            }
            else if action == "resume" {
                self.resume(scriptName)
            }
            else if action == "vars" {
                self.vars(scriptName)
            }
            else if action == "debug" {
                self.debug(scriptName, level: dict["param"])
            } else if action == "list" {
                self.listAll()
            }
        }
    }
    
    private func abort(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? IScript {
                
                if name == "all" || script.scriptName == name {
                    script.cancel()
                }
                
                if name != "all" {
                    break
                }
            }
        }
    }
    
    private func pause(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? IScript {
                
                if name == "all" || script.scriptName == name {
                    script.pause()
                }
                
                if name != "all" {
                    break
                }
            }
        }
    }
    
    private func resume(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? IScript {
                
                if name == "all" || script.scriptName == name {
                    script.resume()
                }
                
                if name != "all" {
                    break
                }
            }
        }
    }
    
    private func vars(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? IScript where script.scriptName == name {
                script.vars()
                break
            }
        }
    }
    
    private func debug(name:String, level:String?) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if var script = q as? IScript where script.scriptName == name {
                var levelNum = level?.toInt()
                script.setLogLevel(ScriptLogLevel(rawValue: levelNum ?? -1) ?? ScriptLogLevel.None)
                break
            }
        }
    }
    
    private func listAll() {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if var script = q as? IScript {
                script.printInfo()
            }
        }
    }
    
    private func notifyVars(vars:[String:String]) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if var script = q as? IScript {
                script.varsChanged(vars)
            }
        }
    }
}
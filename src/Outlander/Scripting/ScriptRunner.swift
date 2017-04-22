//
//  ScriptRunner.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
open class ScriptRunner : NSObject, ISubscriber {
    
    class func newInstance(_ context:GameContext, notifier:INotifyMessage) -> ScriptRunner {
        return ScriptRunner(context: context, notifier: notifier)
    }
    
    var notifier:INotifyMessage
    var context:GameContext
    var scriptLoader:ScriptLoader
   
    fileprivate var scripts:[IScript]
    
    init(context:GameContext, notifier:INotifyMessage) {
        
        self.context = context
        self.notifier = notifier
        self.scriptLoader = ScriptLoader(self.context, and: LocalFileSystem())
        self.scripts = []
        
        super.init()
        
        _ = context.events.subscribe(self, token: "startscript")
        _ = context.events.subscribe(self, token: "script")
        _ = context.events.subscribe(self, token: "ol:game-parse")
        _ = context.events.subscribe(self, token: "ol:game-stream")
        
        self.context.globalVars.changed.subscribeNext { (obj:Any?) -> Void in
            
            if let changed = obj as? Dictionary<String, String> {
                self.notifyVars(changed)
            }
        }
    }
    
    open func handle(_ token:String, data:[String:AnyObject]) {
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
    
    func start(_ dict:[String:AnyObject]) {
        
        let scriptName = dict["target"] as! String
        let tokens = dict["args"] as? NSArray;

        if(!self.scriptLoader.exists(scriptName)) {
            self.context.events.echoText("Cannot find script \(scriptName).cmd", mono: true, preset: "scripterror")
            return
        }
        
        self.abort(scriptName)

        do {
            let script = try Script(
                self.notifier,
                { name in
                    return self.scriptLoader.load(name)
                },
                scriptName,
                self.context,
                {
                    self.abort(scriptName)
                })

            self.scripts.append(script)
            self.context.events.publish("script:add", data: ["scriptName":script.fileName as AnyObject])

            DispatchQueue.global(qos: .background).async {
                script.run(self.argsToParams(tokens))
            }
        }
        catch {
            self.abort(scriptName)
        }
    }

    fileprivate func remove(_ name:String) {
        let found = self.scripts.find { $0.fileName == name }
        if let idx = found {
            self.scripts.remove(at: idx)
            self.context.events.publish("script:remove", data: ["scriptName":name as AnyObject])
        }
    }
    
    func argsToParams(_ args:NSArray?) -> [String] {
        if let input = args {
            var params:[String] = []
            
            for item in input {
                params.append(item as! String)
            }
            
            return params
        }
        
        return []
    }
    
    func stream(_ dict:[String:AnyObject]) {
        let nodes = dict["nodes"] as! [Node]
        let text = dict["text"] as! String
        
        for (_, script) in self.scripts.enumerated() {
            script.stream(text, nodes)
        }
    }
    
    func parse(_ userInfo:[String:AnyObject]) {
        if let dict = userInfo as? [String:String] {
            let text = dict["text"] ?? ""
            
            for (_, script) in self.scripts.enumerated() {
                script.stream(text, [])
            }
        }
    }
    
    func manage(_ userInfo:[String:AnyObject]) {
        if let dict = userInfo as? [String:String] {
            let scriptName = dict["target"]!
            let action = dict["action"]!
            
            if action == "abort" {
                self.abort(scriptName)
                
                if scriptName == "all" {
                    self.context.events.publish("script:removeAll", data: [:])
                }
            }
            else if action == "pause" {
                self.pause(scriptName)
                self.context.events.publish("script:pause", data: ["scriptName":scriptName as AnyObject])
            }
            else if action == "resume" {
                self.resume(scriptName)
                self.context.events.publish("script:resume", data: ["scriptName":scriptName as AnyObject])
            }
            else if action == "trace" {
                self.stackTrace(scriptName)
            }
            else if action == "vars" {
                self.vars(scriptName)
            }
            else if action == "debug" {
                let levelNum = Int(dict["param"] ?? "")
                let level = ScriptLogLevel(rawValue: levelNum ?? -1) ?? ScriptLogLevel.none
                self.debug(scriptName, level: level)

                var data = [String:AnyObject]()
                data["scriptName"] = scriptName as AnyObject?
                data["level"] = level.rawValue as AnyObject?
                
                self.context.events.publish("script:debug", data: data)
            } else if action == "list" {
                self.listAll()
            }
        }
    }
    
    fileprivate func abort(_ name:String) {
        var names:[String] = []
        for (_, script) in self.scripts.enumerated() {
            if name == "all" || script.fileName == name {
                script.stop()
                names.append(script.fileName)
                
                if name != "all" {
                    break
                }
            }
        }
        
        if name == "all" {
            self.scripts = []
        } else {
            for n in names {
                self.remove(n)
            }
        }
    }
    
    fileprivate func pause(_ name:String) {
        for (_, script) in self.scripts.enumerated() {
            
            if name == "all" || script.fileName == name {
                script.pause()

                if name != "all" {
                    break
                }
            }
        }
    }
    
    fileprivate func resume(_ name:String) {
        for (_, script) in self.scripts.enumerated() {
            
            if name == "all" || script.fileName == name {
                script.resume()

                if name != "all" {
                    break
                }
            }
        }
    }
    
    fileprivate func vars(_ name:String) {
        for (_, script) in self.scripts.enumerated() {
            if script.fileName == name {
                script.vars()
                break
            }
        }
    }

    fileprivate func stackTrace(_ name:String) {
        for (_, script) in self.scripts.enumerated() {
            if script.fileName == name {
                script.showStackTrace()
                break
            }
        }
    }
    
    fileprivate func debug(_ name:String, level:ScriptLogLevel) {
        for (_, script) in self.scripts.enumerated() {
            if script.fileName == name {
                script.setLogLevel(level)
                break
            }
        }
    }
    
    fileprivate func listAll() {
        for (_, script) in self.scripts.enumerated() {
//            script.printInfo()
        }
        
        if self.scripts.count == 0 {
            self.notifier.notify(TextTag("\n[No scripts current running.]\n\n", mono: true))
        }
    }
    
    fileprivate func notifyVars(_ vars:[String:String]) {
        for (_, script) in self.scripts.enumerated() {
//            script.varsChanged(vars)
        }
    }
}

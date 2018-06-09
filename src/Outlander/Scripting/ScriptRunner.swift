//
//  ScriptRunner.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public class ScriptRunner : NSObject, ISubscriber {
    
    class func newInstance(context:GameContext, notifier:INotifyMessage) -> ScriptRunner {
        return ScriptRunner(context: context, notifier: notifier)
    }
    
    var notifier:INotifyMessage
    var context:GameContext
    var scriptLoader:ScriptLoader

    private var scripts:[IScript]
    
    init(context:GameContext, notifier:INotifyMessage) {
        
        self.context = context
        self.notifier = notifier
        self.scriptLoader = ScriptLoader(self.context, and: LocalFileSystem())
        self.scripts = []
        
        super.init()
        
        context.events.subscribe(self, token: "startscript")
        context.events.subscribe(self, token: "script")
        context.events.subscribe(self, token: "ol:game-parse")
        context.events.subscribe(self, token: "ol:game-stream")
        context.events.subscribe(self, token: "variable:changed")
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
        } else if token == "variable:changed" {
            if let changed = data as? Dictionary<String, String> {
                self.notifyVars(changed)
            }
        }
    }
    
    func start(dict:[String:AnyObject]) {
        
        let scriptName = dict["target"] as! String
        let tokens = dict["args"] as? NSArray;

        if(!self.scriptLoader.exists(scriptName)) {
            self.context.events.echoText("Cannot find script \(scriptName).cmd", mono: true, preset: "scripterror")
            return
        }
        
        self.abort(scriptName, [])
        self.updateActiveScriptVars()

        self.loadAsync(scriptName, tokens: tokens)
    }
    
    struct ScriptLoadResult {
        var script:IScript?
        var params:[String]
        var scriptText:String?
    }
    
    func loadAsync(scriptName:String, tokens:NSArray?) {
        { () -> ScriptLoadResult in
            var script:IScript?
            var params:[String] = []
            var scriptText:String?
            
            if let text = self.scriptLoader.load(scriptName) {
                
                params = self.argsToParams(tokens)
                script = Script(scriptName, self.notifier)
                scriptText = text
            }
            
            return ScriptLoadResult(script: script,  params: params, scriptText: scriptText)
        } ~> { res -> () in
          
            self.runScript(res)
            
//            let diff = NSDate().timeIntervalSinceDate(start)
//            
//            println("\(scriptName) loaded in \(diff)")
        }
    }
    
    private func runScript(res:ScriptLoadResult) {
        
        if var script = res.script {
            self.scripts.append(script)
            
            script.completed = { (name, msg) in
                print(msg)
                self.remove(name)
            }
            
            script.run(res.scriptText!, context: self.context, params: res.params)

            self.context.events.publish("script:add", data: ["scriptName":script.scriptName])
            self.updateActiveScriptVars()
        }
    }
    
    private func remove(name:String) {
        let found = self.scripts.find { $0.scriptName == name }
        if let idx = found {
            self.scripts.removeAtIndex(idx)
            self.context.events.publish("script:remove", data: ["scriptName":name])
            self.updateActiveScriptVars()
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
        let nodes = dict["nodes"] as! [Node]
        let text = dict["text"] as! String
        
        for (_, script) in self.scripts.enumerate() {
            script.stream(text, nodes: nodes)
        }
    }
    
    func parse(userInfo:[String:AnyObject]) {
        if let dict = userInfo as? [String:String] {
            let text = dict["text"] ?? ""
            
            for (_, script) in self.scripts.enumerate() {
                script.stream(text, nodes: [])
            }
        }
    }
    
    func manage(userInfo:[String:AnyObject]) {
        let scriptName = userInfo["target"] as! String
        let action = userInfo["action"] as! String
        let param1 = userInfo["param"] as? String ?? ""
        let param2 = userInfo["param2"] as? [String] ?? []

        let except:[String] = param1 == "except" ? param2 : []
        
        if action == "abort" {
            self.abort(scriptName, except)
            
            if scriptName == "all" && except.count == 0 {
                self.context.events.publish("script:removeAll", data: ["except":except])
            }
        }
        else if action == "pause" {
            self.pause(scriptName, except)
            self.context.events.publish("script:pause", data: ["scriptName":scriptName, "except":except])
        }
        else if action == "resume" {
            self.resume(scriptName, except)
            self.context.events.publish("script:resume", data: ["scriptName":scriptName, "except":except])
        }
        else if action == "vars" {
            self.vars(scriptName)
        }
        else if action == "debug" {
            let levelNum = Int(param1)
            let level = ScriptLogLevel(rawValue: levelNum ?? -1) ?? ScriptLogLevel.None
            self.debug(scriptName, level: level)
            
            var data = [String:AnyObject]()
            data["scriptName"] = scriptName
            data["level"] = level.rawValue
            
            self.context.events.publish("script:debug", data: data)
        } else if action == "list" {
            self.listAll()
        }

        self.updateActiveScriptVars()
    }
    
    private func abort(name:String, _ except:[String]) {
        var names:[String] = []
        for (_, script) in self.scripts.enumerate() {
            if (name == "all" && !except.contains(script.scriptName)) || script.scriptName == name {
                script.cancel()
                names.append(script.scriptName)
                
                if name != "all" {
                    break
                }
            }
        }
        
        if name == "all" && except.count == 0 {
            self.scripts = []
        } else {
            for n in names {
                self.remove(n)
            }
        }
    }
    
    private func pause(name:String, _ except:[String]) {
        for (_, script) in self.scripts.enumerate() {
            
            if (name == "all" && !except.contains(script.scriptName)) || script.scriptName == name {
                script.pause()
                
                if name != "all" {
                    break
                }
            }
        }
    }
    
    private func resume(name:String, _ except:[String]) {
        for (_, script) in self.scripts.enumerate() {
            
            if (name == "all" && !except.contains(script.scriptName)) || script.scriptName == name {
                script.resume()
                
                if name != "all" {
                    break
                }
            }
        }
    }
    
    private func vars(name:String) {
        for (_, script) in self.scripts.enumerate() {
            if script.scriptName == name {
                script.vars()
                break
            }
        }
    }
    
    private func debug(name:String, level:ScriptLogLevel) {
        for (_, script) in self.scripts.enumerate() {
            if script.scriptName == name {
                script.setLogLevel(level)
                break
            }
        }
    }
    
    private func listAll() {
        for (_, script) in self.scripts.enumerate() {
            script.printInfo()
        }
        
        if self.scripts.count == 0 {
            self.notifier.notify(TextTag("\n[No scripts current running.]\n\n", mono: true))
        }
    }
    
    private func notifyVars(vars:[String:String]) {
        for (_, script) in self.scripts.enumerate() {
            script.varsChanged(vars)
        }
    }

    private func updateActiveScriptVars() {
        var scriptNames:[String] = []
        var activeNames:[String] = []
        var pausedNames:[String] = []

        for (_, script) in self.scripts.enumerate() {
            scriptNames.append(script.scriptName)
            if script.paused {
                pausedNames.append(script.scriptName)
            } else {
                activeNames.append(script.scriptName)
            }
        }

        self.context.globalVars["scriptlist"] = scriptNames.joinWithSeparator(" ")
        self.context.globalVars["activescriptlist"] = activeNames.joinWithSeparator(" ")
        self.context.globalVars["pausedscriptlist"] = pausedNames.joinWithSeparator(" ")
    }
}

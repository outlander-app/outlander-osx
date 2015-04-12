//
//  ScriptRunner.swift
//  Outlander
//
//  Created by Joseph McBride on 4/11/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class ScriptRunner {
    
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
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector:Selector("start:"), name: "startscript", object: nil)
        
        NSNotificationCenter
            .defaultCenter()
            .addObserver(self, selector:Selector("manage:"), name: "script", object: nil)
    }
    
    func start(notification:NSNotification) {
        
        if let dict = notification.userInfo as? Dictionary<String, AnyObject> {
            var scriptName = dict["target"] as! String
            if let scriptText = self.scriptLoader.load(scriptName) {
                
                var script = Script(scriptName, self.notifier, self.thread)
                
                self.thread.addOperation(script)
                
//                script.run(script: "", globalVars: { () -> [String : String] in
//                    
//                }, params: <#[String]#>)
                
                script.run(scriptText, globalVars: { () -> [String:String] in
                    return self.context.globalVars.copyValues() as! [String:String]
                }, params: [])
            }
        }
    }
    
    func manage(notification:NSNotification) {
        if let dict = notification.userInfo as? [String:String] {
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
        }
    }
    
    private func abort(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? Script where script.scriptName == name {
                script.cancel()
                break
            }
        }
    }
    
    private func pause(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? Script where script.scriptName == name {
                script.pause()
                break
            }
        }
    }
    
    private func resume(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? Script where script.scriptName == name {
                script.resume()
                break
            }
        }
    }
    
    private func vars(name:String) {
        for (index, q) in enumerate(self.thread.queue.operations) {
            if let script = q as? Script where script.scriptName == name {
                script.vars()
                break
            }
        }
    }
}
//
//  File.swift
//  Outlander
//
//  Created by Joseph McBride on 4/25/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
public protocol ISubscriber {
    func handle(token:String, data:Dictionary<String, AnyObject>)
}

@objc
public class EventAggregator {
    
    private var handlers:[EventHandler]
    
    init() {
        handlers = []
    }
    
    public func subscribe(subscriber:ISubscriber, token:String) -> String {
        
        var id = NSUUID().UUIDString
        
        self.handlers.append(EventHandler(
            id: id,
            subscriber: subscriber,
            token: token
        ))
       
        return id
    }
    
    public func unSubscribe(id:String) {
        var idx = self.handlers.find { $0.id == id }
        if let found = idx {
            self.handlers.removeAtIndex(found)
        }
    }
    
    public func publish(token:String, data:Dictionary<String, AnyObject>) {
        var events = self.handlers.filter { $0.token == token }
        
        for ev in events {
            if let sub = ev.subscriber {
                sub.handle(token, data: data)
            }
        }
    }
}

public struct EventHandler {
    var id:String
    weak var subscriber:ISubscriber?
    var token:String
}
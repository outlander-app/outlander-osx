//
//  EventAggregator.swift
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
public class EventAggregator : NSObject {
    
    private var handlers:[EventHandler]
    
    override init() {
        handlers = []
    }
    
    public func subscribe(subscriber:ISubscriber, token:String) -> String {
        
        let id = NSUUID().UUIDString
        
        let handler = EventHandler(
            id: id,
            subscriber: subscriber,
            token: token
        )
        
        self.handlers.append(handler)
       
        return id
    }
    
    public func unSubscribe(id:String) {
        let idx = self.handlers.find { $0.id == id }
        if let found = idx {
            self.handlers.removeAtIndex(found)
        }
    }
    
    public func unSubscribeListener(subscriber:ISubscriber) {
        let res = self.handlers.filter { $0.subscriber === subscriber }
        
        for sub in res {
            let idx = self.handlers.find { $0.id == sub.id }
            if let found = idx {
                self.handlers.removeAtIndex(found)
            }
        }
    }
    
    public func unSubscribeAll() {
        self.handlers = []
    }
    
    public func publish(token:String, data:Dictionary<String, AnyObject>) {
        let events = self.handlers.filter { $0.token == token }
        
        for ev in events {
            if let sub = ev.subscriber {
                sub.handle(token, data: data)
            }
        }
    }
}

public struct EventHandler {
    var id:String
    // TODO: this should be weak, though swift sometimes crashes with it
    var subscriber:ISubscriber?
    var token:String
}

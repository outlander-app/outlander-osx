//
//  Utilities.swift
//  Outlander
//
//  Created by Joseph McBride on 6/1/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

@objc
public protocol IClock {
    var now:NSDate { get }
}

@objc
public class Clock : NSObject, IClock {

    private var get:()->NSDate

    override convenience init() {
        self.init({ NSDate() })
    }

    init(_ get:()->NSDate) {
        self.get = get
    }
    
    public var now:NSDate {
        return self.get()
    }
}

public typealias FuncValue = ()->String?

public enum DynamicValue {
    case none
    case value(String?)
    case dynamic(FuncValue)

    var isDynamic:Bool {
        switch self {
        case .dynamic: return true
        default: return false
        }
    }

    var rawValue:String? {
        switch self {
        case .none: return nil
        case .value(let val): return val
        case .dynamic(let dynamic): return dynamic()
        }
    }
}

public class GlobalVariables : ConcurrentDictionary {

    private static let dateFormatter:NSDateFormatter = NSDateFormatter()

    private var clock:IClock
    private var settings:AppSettings
    private var dynamicKeys:[String]

    init(_ name: String, _ clock:IClock, _ settings:AppSettings) {
        self.clock = clock
        self.settings = settings
        self.dynamicKeys = []

        super.init(name: name)
        self.setDynamics()
    }

    override public func set(value: String?, forKey key: String) {
        guard !dynamicKeys.contains(key) else { return }
        super.set(value, forKey: key)
    }

    override public func setDynamic(value: FuncValue, forKey key: String) {
        dynamicKeys.append(key)
        super.setDynamic(value, forKey: key)
    }

    override public func removeAll() {
        dynamicKeys.removeAll()
        super.removeAll()
        self.setDynamics()
    }

    override public func removeValueForKey(key: String) {
        if let index = dynamicKeys.indexOf(key) {
            dynamicKeys.removeAtIndex(index)
        }
        super.removeValueForKey(key)
    }

    private func setDynamics() {
        self.setDynamic({
            GlobalVariables.dateFormatter.dateFormat = self.settings.variableDateFormat
            return GlobalVariables.dateFormatter.stringFromDate(self.clock.now)
        }, forKey: "date")
        
        self.setDynamic({
            GlobalVariables.dateFormatter.dateFormat = self.settings.variableTimeFormat
            return GlobalVariables.dateFormatter.stringFromDate(self.clock.now)
        }, forKey: "time")

        self.setDynamic({
            GlobalVariables.dateFormatter.dateFormat = self.settings.variableDatetimeFormat
            return GlobalVariables.dateFormatter.stringFromDate(self.clock.now)
        }, forKey: "datetime")
    }
}

@objc
public class ConcurrentDictionary : NSObject, SequenceType {

    private var internalDictionary:[String:DynamicValue]
    private var listeners:[(String, String?)->Void]

    init(name:String) {
        self.internalDictionary = [:]
        self.listeners = []
        super.init()
    }

    public var count : Int {
        return self.internalDictionary.count
    }

    public var keys : [String] {
        return self.internalDictionary.keysByLength
    }

    public var alphabeticalKeys : [String] {
        return self.internalDictionary.keysByAlpha
    }

    public var hasOnlyDynamicValues : Bool {

        for pair in internalDictionary {
            switch pair.1 {
            case .value: return false
            default: continue
            }
        }
        
        return true
    }

    public func sortedKeys(predicate: (String, String)->Bool) -> [String] {
        return self.internalDictionary.keys.sort({ predicate($0.0, $0.1) })
    }

    subscript(key: String) -> String? {
        get {
            return get(key)
        }
        
        set {
            set(newValue, forKey: key)
        }
    }

    public func get(key:String) -> String? {
        return self.internalDictionary[key]?.rawValue
    }

    public func set(value:String?, forKey key:String) {
        let val:DynamicValue = .value(value)
        self.internalDictionary[key] = val
        self.notify(key, val)
    }

    public func setDynamic(value:FuncValue, forKey key:String) {
        let val:DynamicValue = .dynamic(value)
        self.internalDictionary[key] = val
        self.notify(key, val)
    }

    public func hasKey(key:String) -> Bool {
        return self.internalDictionary.keysByLength.contains(key)
    }

    public func removeAll() {
        self.internalDictionary.removeAll()
    }

    public func removeValueForKey(key: String) {
        self.internalDictionary.removeValueForKey(key)
        self.notify(key, .none)
    }

    public func listen(listener:(String, String?)->Void) {
        self.listeners.append(listener)
    }

    public func generate() -> Dictionary<String,DynamicValue>.Generator {
        return self.internalDictionary.generate()
    }

    private func notify(key:String, _ value:DynamicValue) {
        for listener in self.listeners {
            listener(key, value.rawValue)
        }
    }
}

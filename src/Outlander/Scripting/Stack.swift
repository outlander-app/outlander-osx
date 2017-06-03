//
//  Stack.swift
//  Outlander
//
//  Created by Joseph McBride on 4/5/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class Stack<T> {

    private var stack:[T] = []
    var maxCapacity = 0

    init(_ capacity:Int = 0) {
        self.maxCapacity = capacity
    }

    var items:[T] {
        return stack
    }

    var last:T? {
        return stack.last
    }

    var last2:T? {
        if stack.count < 2 {
            return nil
        }
        
        return stack[stack.count - 2]
    }

    var count:Int {
        return stack.count
    }

    func push(_ item:T) {
        stack.append(item)

        if self.maxCapacity > 0 && stack.count > self.maxCapacity {
            stack.removeFirst()
        }
    }

    func pop() -> T? {
        guard hasItems() else { return nil }
        return stack.removeLast()
    }

    func hasItems() -> Bool {
        return stack.count > 0
    }

    func clear() {
        stack.removeAll(keepingCapacity: true)
    }
}

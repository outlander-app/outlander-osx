//
//  Threading.swift
//  SwiftThreading
//
//  Created by Joshua Smith on 7/5/14.
//  Copyright (c) 2014 iJoshSmith. All rights reserved.
//

import Foundation

infix operator ~>

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
*/
func ~> (
    backgroundClosure: @escaping () -> (),
    mainClosure:       @escaping () -> ())
{
    queue.async {
        backgroundClosure()
        DispatchQueue.main.async(execute: mainClosure)
    }
}

/**
Executes the lefthand closure on a background thread and,
upon completion, the righthand closure on the main thread.
Passes the background closure's output to the main closure.
*/
func ~> <R> (
    backgroundClosure: @escaping () -> R,
    mainClosure:       @escaping (_ result: R) -> ())
{
    queue.async {
        let result = backgroundClosure()
        DispatchQueue.main.async(execute: {
            mainClosure(result)
        })
    }
}

/** Serial dispatch queue used by the ~> operator. */
private let queue = DispatchQueue(label: "serial-worker", attributes: [])

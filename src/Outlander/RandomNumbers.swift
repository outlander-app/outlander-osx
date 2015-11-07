//
//  RandomNumbers.swift
//  Outlander
//
//  Created by Joseph McBride on 4/18/15.
//  https://gist.github.com/indragiek/b16f95d911a37cb963a7
//

import Foundation

public struct RandomNumberGenerator: SequenceType {
    let range: Range<Int>
    let count: Int
    
    public init(range: Range<Int>, count: Int) {
        self.range = range
        self.count = count
    }
    
    public func generate() -> AnyGenerator<Int> {
        var i = 0
        return anyGenerator {
            return (i++ == self.count) ? .None : randomNumberFrom(self.range)
        }
    }
}

public func randomNumberFrom(from: Range<Int>) -> Int {
    return from.startIndex + Int(arc4random_uniform(UInt32(from.endIndex - from.startIndex)))
}

public func randomNumbersFrom(from: Range<Int>, count: Int) -> RandomNumberGenerator {
    return RandomNumberGenerator(range: from, count: count)
}
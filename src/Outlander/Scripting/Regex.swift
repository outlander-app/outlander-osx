//
//  Regex.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String

    init(_ pattern: String) throws {
        self.pattern = pattern
        self.internalExpression = try NSRegularExpression(pattern: pattern, options: .AnchorsMatchLines)
    }

    func test(input: String) -> Bool {
        let matches = matchResults(input)
        return matches.count > 0
    }

    func firstMatch(input: NSString, options: NSMatchingOptions? = nil ) -> String? {
        if let match =  matchResults( input as String, options ).first {
            let range = match.rangeAtIndex(1)
            return input.substringWithRange(range)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }

        return nil
    }

    func groups(input: NSString, options: NSMatchingOptions? = nil ) -> [String] {
        let matches =  matchResults( input as String, options )
        return matches.map {
            let range = $0.rangeAtIndex(1)
            return input.substringWithRange(range)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        }
    }

    func matchResults(input: String, _ options: NSMatchingOptions? = nil ) -> [NSTextCheckingResult] {
        return self.internalExpression.matchesInString(
            input,
            options: options ?? NSMatchingOptions(rawValue: 0),
            range: NSMakeRange(0, input.characters.count) )
    }
}

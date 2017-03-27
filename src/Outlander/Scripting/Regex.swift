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
        self.internalExpression = try NSRegularExpression(pattern: pattern, options: .anchorsMatchLines)
    }

    func test(_ input: String) -> Bool {
        let matches = matchResults(input)
        return matches.count > 0
    }

    func firstMatch(_ input: NSString, options: NSRegularExpression.MatchingOptions? = nil ) -> String? {
        if let match =  matchResults( input as String, options ).first {
            let range = match.rangeAt(1)
            return input.substring(with: range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }

        return nil
    }

    func groups(_ input: NSString, options: NSRegularExpression.MatchingOptions? = nil ) -> [String] {
        let matches =  matchResults( input as String, options )
        return matches.map {
            let range = $0.rangeAt(1)
            return input.substring(with: range)
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }

    func matchResults(_ input: String, _ options: NSRegularExpression.MatchingOptions? = nil ) -> [NSTextCheckingResult] {
        return self.internalExpression.matches(
            in: input,
            options: options ?? NSRegularExpression.MatchingOptions(rawValue: 0),
            range: NSMakeRange(0, input.characters.count) )
    }
}

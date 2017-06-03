//
//  CharacterExtension.swift
//  Outlander
//
//  Created by Joseph McBride on 3/26/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

extension Character {

    /// The first `UnicodeScalar` of `self`.
    var unicodeScalar: UnicodeScalar {

        let unicodes = String(self).unicodeScalars
        return unicodes[unicodes.startIndex]

    }

    /// True for any space character, and the control characters \t, \n, \r, \f, \v.
    var isSpace: Bool {

        switch self {

        case " ", "\t", "\n", "\r", "\r\n": return true

        case "\u{000B}", "\u{000C}": return true // Form Feed, vertical tab

        default: return false

        }
    }

    var lowercase: Character {
        let str = String(self).lowercased()
        return str[str.startIndex]
    }

    var uppercase: Character {
        let str = String(self).uppercased()
        return str[str.startIndex]
    }
}

extension Sequence where Iterator.Element == Int {

    /// Converts each `Int` in its `Character` equivalent and build a String
    /// with the result.
    var stringValue: String {

        let chars = map { Character(UnicodeScalar($0)!) }

        return String(chars)

    }
}

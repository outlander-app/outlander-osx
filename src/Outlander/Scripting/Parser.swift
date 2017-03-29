//
//  Parser.swift
//  Outlander
//
//  Created by Joseph McBride on 3/27/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import FootlessParser

class ScriptParser {

    typealias P<T> = Parser<Character, T>
    
    func csvparse(_ input:String) -> [[String]]{

        let delimiter = "," as Character
        let quote = "\"" as Character
        let newline = "\n" as Character

        let cell = char(quote) *> zeroOrMore(not(quote)) <* char(quote) <|> zeroOrMore(noneOf([delimiter, newline]))

        let row = extend <^> cell <*> zeroOrMore( char(delimiter) *> cell ) <* char(newline)
        let csvparser = zeroOrMore(row)

        do {
            let output = try FootlessParser.parse(csvparser, input)
            return output
        } catch {
            return []
        }
    }

    private static func word() -> P<String> {
        return oneOrMore(satisfy(expect: "word") { (char: Character) in
            return String(char).rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines) == nil
        })
    }
}

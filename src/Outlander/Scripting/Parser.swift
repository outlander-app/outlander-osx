////
////  Parser.swift
////  Outlander
////
////  Created by Joseph McBride on 3/27/17.
////  Copyright © 2017 Joe McBride. All rights reserved.
////
//
//import FootlessParser
//
//enum ScriptToken {
//    case put([String])
//}
//
//class ScriptParser {
//
//    typealias P<T> = Parser<Character, T>
//    private static let ws = zeroOrMore(whitespace)
//
//    func parse(_ input:String) {
//        let newline = "\n" as Character
//
//        let word = zeroOrMore(noneOf([newline]))
//
//        let put = { _ in ScriptTokens.put($0) } <^> string("put") *> zeroOrMore(word)
//
//        let row = word <* char(newline)
//        let parser = zeroOrMore(row)
//
//        do {
//            let output = try FootlessParser.parse(parser, input + "\n")
//
//            print("\n")
//            print(output)
//            print("\n")
//
//        } catch {
//        }
//    }
//
//    func csvparse(_ input:String) -> [[String]]{
//
//        let delimiter = "," as Character
//        let quote = "\"" as Character
//        let newline = "\n" as Character
//
//        let cell = char(quote) *> zeroOrMore(not(quote)) <* char(quote) <|> zeroOrMore(noneOf([delimiter, newline]))
//
//        let row = extend <^> cell <*> zeroOrMore( char(delimiter) *> cell ) <* char(newline)
//        let csvparser = zeroOrMore(row)
//
//        do {
//            let output = try FootlessParser.parse(csvparser, input + "\n")
//            return output
//        } catch {
//            return []
//        }
//    }
//
//    func put() -> P<ScriptToken> {
//        let newline:Character = "\n"
//        let word = zeroOrMore(noneOf([newline]))
//        return { curry(ScriptToken.put($0)) } <^> string("put") *> zeroOrMore(word)
//    }
//
//    func labelAndText() -> P<String> {
//    }
//
//    private static func word() -> P<String> {
//        return oneOrMore(satisfy(expect: "word") { (char: Character) in
//            return !CharacterSet.whitespacesAndNewlines.contains(char.unicodeScalar)
//        })
//    }
//}

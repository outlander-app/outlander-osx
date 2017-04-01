//
//  Parser2.swift
//  Outlander
//
//  Created by Joseph McBride on 3/28/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

enum TokenValue {
    case debug(Int)
    case label(String)
    case put(String)
    case pause(Double)
    case send(String)
    case echo(String)
    case goto(String)
    case exit

    case variable(String, String)
    case gosub(String, [String])
    case move(String)
    case nextroom
    case wait
    case waitfor(String)
    case waitforre(String)
    case waiteval(String)
    case match(String)
    case matchre(String)
    case matchwait(Double)
    case shift
    case save
    case ifArg(Int)
    case random(Double, Double)
    case unvar(String)
    case action
}

class ScriptParser {

    let space = character(condition: { CharacterSet.whitespaces.contains($0.unicodeScalar) })
    let ws = character(condition: { CharacterSet.whitespacesAndNewlines.contains($0.unicodeScalar) })
    let newline = character(condition: { CharacterSet.newlines.contains($0.unicodeScalar) })

    let anyChar = character(condition: { !CharacterSet.newlines.contains($0.unicodeScalar) })

    let colon:Character = ":"
    
    let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })

    func parse(_ input:String) -> TokenValue? {

        let int = digit.oneOrMore.map { characters in Int(String(characters))! }
        
        let double = curry({ x, y in Double("\(x).\(y ?? 0)")! }) <^> int <*> (char(".") *> int).optional

        let identifier = (character(condition: { swiftIdentifierLetterSet.contains($0.unicodeScalar) }) <&> character(condition: { swiftIdentifierLetterSet.contains($0.unicodeScalar) }).many.map { String($0) }.optional).map { s, r in String(s) + String(r ?? "") }

        let label = TokenValue.label <^> identifier <* char(colon)

        let debug = TokenValue.debug <^> ((symbol("debug") *> int) <|> symbolOnly("debug", 1))

        let pause = TokenValue.pause <^> ((symbol("pause") *> double) <|> symbolOnly("pause", 1))

        let put = TokenValue.put <^> lineCommand("put")
        let send = TokenValue.send <^> lineCommand("send")
        let echo = TokenValue.echo <^> lineCommand("echo")
        let goto = TokenValue.goto <^> lineCommand("goto")
        let exit = TokenValue.exit <^^> symbolOnly("exit", "")

        let row = ws.many.optional *> (label <|> put <|> pause <|> echo <|> send <|> goto <|> exit <|> debug) <* ws.many.optional

        let actualInput = input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "\n"
        let parseResult = row.run(actualInput)

        return parseResult?.0
    }

    public func char(_ c:Character) -> Parser<Character> {
        return character(condition: { $0 == c })
    }

    public func symbol(_ s:String) -> Parser<String> {
        return (string(s) <* space)
    }

    public func lineCommand(_ s:String) -> Parser<String> {
        let any = anyChar.many.map { String($0) }
        return ((symbol(s) *> any).map { $0.trimEnd(CharacterSet.whitespaces) }) <|> symbolOnly(s, "")
    }

    public func symbolOnly<A>(_ s:String, _ val:A) -> Parser<A> {
        return (string(s) *> newline *> result(val))
    }

    public func result<A>(_ res:A) -> Parser<A> {
        return Parser { stream in
            return (res, stream)
        }
    }
}

private let swiftIdentifierStartCharacters =
    (0x0041...0x005A).stringValue + // 'A' to 'Z'
    (0x0061...0x007A).stringValue + // 'a' to 'z'
    "_"

private let swiftIdentifierStartSet =
    CharacterSet(charactersIn: swiftIdentifierStartCharacters)

private let swiftIdentifierLetterCharacters =
    swiftIdentifierStartCharacters +
        "0123456789" +
        "." +
        (0x0300...0x036F).stringValue +
        (0x1DC0...0x1DFF).stringValue +
        (0x20D0...0x20FF).stringValue +
        (0xFE20...0xFE2F).stringValue

private let swiftIdentifierLetterSet =
    CharacterSet(charactersIn: swiftIdentifierLetterCharacters)

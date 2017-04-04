//
//  Parser2.swift
//  Outlander
//
//  Created by Joseph McBride on 3/28/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

enum TokenValue {
    case comment(String)
    case debug(Int)
    case echo(String)
    case exit
    case goto(String)
    case label(String)
    case matchwait(Double)
    case move(String)
    case nextroom
    case put(String)
    case pause(Double)
    case save(String)
    case send(String)
    case shift
    case unvar(String)
    case wait
    case waitfor(String)
    case waitforre(String)

    case variable(String, String)
    case gosub(String, [String])
    case waiteval(String)
    case match(String, String)
    case matchre(String, String)
    case ifArg(Int)
    case random(Double, Double)
    case action
    case eval
}

class ScriptParser {

    let space = character(condition: { CharacterSet.whitespaces.contains($0.unicodeScalar) })
    let ws = character(condition: { CharacterSet.whitespacesAndNewlines.contains($0.unicodeScalar) })
    let newline = character(condition: { CharacterSet.newlines.contains($0.unicodeScalar) })

    let anyChar = character(condition: { !CharacterSet.newlines.contains($0.unicodeScalar) })

    let colon:Character = ":"
    
    let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })

    func parse(_ input:String) -> TokenValue? {

        let any = anyChar.many.map { String($0) }

        let int = digit.oneOrMore.map { characters in Int(String(characters))! }
        
        let double = curry({ x, y in Double("\(x).\(y ?? 0)")! }) <^> int <*> (char(".") *> int).optional

        let identifier = (character(condition: { swiftIdentifierStartSet.contains($0.unicodeScalar) })
            <&> character(condition: { swiftIdentifierLetterSet.contains($0.unicodeScalar) }).many.map { String($0) }.optional).map { s, r in String(s) + String(r ?? "") }

        let comment = TokenValue.comment <^> (string("#") *> any)

        let label = TokenValue.label <^> identifier <* char(colon)

        let debug = TokenValue.debug <^> ((symbol("debug") *> int) <|> symbolOnly("debug", 1))

        let pause = TokenValue.pause <^> ((symbol("pause") *> double) <|> symbolOnly("pause", 1))

        let matchwait = TokenValue.pause <^> ((symbol("matchwait") *> double) <|> symbolOnly("matchwait", -1))

        let echo = TokenValue.echo <^> lineCommand("echo")
        let goto = TokenValue.goto <^> lineCommand("goto")
        let exit = TokenValue.exit <^^> symbolOnly("exit", "")
        let move = TokenValue.move <^> lineCommand("move")
        let nextroom = TokenValue.nextroom <^^> symbolOnly("nextroom", "")
        let put = TokenValue.put <^> lineCommand("put")
        let save = TokenValue.save <^> lineCommand("save")
        let send = TokenValue.send <^> lineCommand("send")
        let shift = TokenValue.shift <^^> symbolOnly("shift", "")
        let unvar = TokenValue.unvar <^> lineCommand("unvar")
        let wait = TokenValue.wait <^^> symbolOnly("wait", "")
        let waitfor = TokenValue.waitfor <^> lineCommand("waitfor")
        let waitforre = TokenValue.waitforre <^> lineCommand("waitforre")

        let row = ws.many.optional *> (
            comment
            <|> debug
            <|> echo
            <|> exit
            <|> goto
            <|> label
            <|> matchwait
            <|> move
            <|> nextroom
            <|> pause
            <|> put
            <|> save
            <|> send
            <|> shift
            <|> unvar
            <|> wait
            <|> waitfor
            <|> waitforre
        ) <* ws.many.optional

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
        ".-" +
        (0x0300...0x036F).stringValue +
        (0x1DC0...0x1DFF).stringValue +
        (0x20D0...0x20FF).stringValue +
        (0xFE20...0xFE2F).stringValue

private let swiftIdentifierLetterSet =
    CharacterSet(charactersIn: swiftIdentifierLetterCharacters)

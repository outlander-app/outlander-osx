//
//  Parser2.swift
//  Outlander
//
//  Created by Joseph McBride on 3/28/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

enum Expression {
    case value(String)
    case function(String, [String])
    indirect case exp(Expression,Expression)
}

enum TokenValue : Hashable {

    typealias RawValue = Int

    // have handlers
    case comment(String)
    case debug(Int)
    case echo(String)
    case exit
    case goto(String)
    indirect case ifArgSingle(Int, TokenValue)
    case ifArg(Int)
    case ifArgNeedsBrace(Int)
    indirect case ifSingle(String, TokenValue)
    case If(String)
    case ifNeedsBrace(String)
    case elseIf(String)
    case elseIfNeedsBrace(String)
    indirect case elseIfSingle(String, TokenValue)
    case Else
    case elseNeedsBrace
    indirect case elseSingle(TokenValue)
    case gosub(String, String)
    case label(String)
    case match(String, String)
    case matchre(String, String)
    case matchwait(Double)
    case move(String)
    case nextroom
    case pause(Double)
    case put(String)
    case Return
    case save(String)
    case send(String)
    case shift
    case token(String)
    case unvar(String)
    case wait
    case waitfor(String)
    case waitforre(String)
    case variable(String, String)

    // parsed but need handlers

    // not parsed
    case waiteval(String)
    case random(String, String)
    case action
    case actionToggle(String, String)
    case eval(String, String)
    case evalMath(String, String)
    case function(String, [String])

    var rawValue: RawValue {
        switch self {
        case .comment: return 1
        case .debug: return 2
        case .echo: return 3
        case .elseSingle: return 50
        case .Else: return 51
        case .elseNeedsBrace: return 52
        case .elseIf: return 53
        case .elseIfNeedsBrace: return 54
        case .elseIfSingle: return 55
        case .exit: return 4
        case .goto: return 5
        case .gosub: return 97
        case .ifArgSingle: return 98
        case .ifArg: return 99
        case .ifArgNeedsBrace: return 100
        case .ifSingle: return 101
        case .If: return 102
        case .ifNeedsBrace: return 103
        case .label: return 6
        case .match: return 71
        case .matchre: return 72
        case .matchwait: return 73
        case .move: return 7
        case .nextroom: return 8
        case .pause: return 9
        case .put: return 10
        case .Return: return 1000
        case .save: return 11
        case .send: return 12
        case .shift: return 13
        case .token: return 133
        case .unvar: return 14
        case .wait: return 15
        case .waitfor: return 16
        case .waitforre: return 17
        case .variable: return 20
//        default: fatalError("TokenValue is not valid")
        default: return -1
        }
    }

    var isIfToken: Bool {
        switch self {
        case .ifArg: return true
        case .ifArgSingle: return true
        case .ifArgNeedsBrace: return true
        case .ifSingle: return true
        case .If: return true
        case .ifNeedsBrace: return true
        case .elseIfSingle: return true
        case .elseIf: return true
        case .elseIfNeedsBrace: return true
        default: return false
        }
    }

    var isElseToken: Bool {
        switch self {
        case .elseSingle: return true
        case .Else: return true
        case .elseNeedsBrace: return true
        default: return false
        }
    }

    var isSingleToken: Bool {
        switch self {
        case .ifArgSingle: return true
        case .ifSingle: return true
        case .elseIfSingle: return true
        case .elseSingle: return true
        default: return false
        }
    }

    var hashValue: Int {
        return self.rawValue.hashValue
    }

    static func == (lhs: TokenValue, rhs: TokenValue) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

class ScriptParser {

    let space = character(condition: { CharacterSet.whitespaces.contains($0.unicodeScalar) })
    let ws = character(condition: { CharacterSet.whitespacesAndNewlines.contains($0.unicodeScalar) })
    let newline = character(condition: { CharacterSet.newlines.contains($0.unicodeScalar) })

    let anyChar = character(condition: { !CharacterSet.newlines.contains($0.unicodeScalar) })

    let colon:Character = ":"
    
    let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })

    let variableCharacters = CharacterSet(charactersIn: "$%&")

    func parse(_ input:String) -> TokenValue? {

        let any = anyChar.many.map { String($0) }

        let int = digit.oneOrMore.map { characters in Int(String(characters))! }
        
        let double = curry({ x, y in Double("\(x).\(y ?? 0)")! }) <^> int <*> (char(".") *> int).optional

        let identifier = (character(condition: { swiftIdentifierStartSet.contains($0.unicodeScalar) })
            <&> character(condition: { swiftIdentifierLetterSet.contains($0.unicodeScalar) }).many.map { String($0) }.optional).map { s, r in String(s) + String(r ?? "") }

        let variableIdentifier = (character(condition: { self.variableCharacters.contains($0.unicodeScalar) }) <&> identifier).map { s, r in String(s) + r }

        let comment = TokenValue.comment <^> (string("#") *> any)

        let label = TokenValue.label <^> identifier <* char(colon)

        let debug = TokenValue.debug <^> ((symbol("debug") *> int) <|> symbolOnly("debug", 1))
        let debugLevel = TokenValue.debug <^> ((symbol("debuglevel") *> int) <|> symbolOnly("debuglevel", 1))

        let pause = TokenValue.pause <^> ((symbol("pause") *> double) <|> symbolOnly("pause", 1))

        let matchStart = symbol("match") *> identifier <* space
        let match = TokenValue.match <^> matchStart <*> noneOf(["\n"])

        let matchreStart = symbol("matchre") *> identifier <* space
        let matchre = TokenValue.matchre <^> matchreStart <*> noneOf(["\n"])
        
        let matchwait = TokenValue.matchwait <^> ((symbol("matchwait") *> double) <|> symbolOnly("matchwait", -1))

        let args = noneOf(["\n"])

        let gosubStart = symbol("gosub") *> (identifier <|> variableIdentifier)
        let gosub = curry({ label, args in TokenValue.gosub(label, args != nil ? args! : "") }) <^> gosubStart <*> (space *> args).optional

        let deleteVar = TokenValue.unvar <^> lineCommand("deletevariable")
        let echo = TokenValue.echo <^> lineCommand("echo")
        let goto = TokenValue.goto <^> lineCommand("goto")
        let exit = TokenValue.exit <^^> symbolOnly("exit", "")
        let move = TokenValue.move <^> lineCommand("move")
        let nextroom = TokenValue.nextroom <^^> symbolOnly("nextroom", "")
        let put = TokenValue.put <^> lineCommand("put")
        let returnToken = TokenValue.Return <^^> symbolOnly("return", "")
        let save = TokenValue.save <^> lineCommand("save")
        let send = TokenValue.send <^> lineCommand("send")
        let shift = TokenValue.shift <^^> symbolOnly("shift", "")
        let unvar = TokenValue.unvar <^> lineCommand("unvar")
        let wait = TokenValue.wait <^^> symbolOnly("wait", "")
        let waitfor = TokenValue.waitfor <^> lineCommand("waitfor")
        let waitforre = TokenValue.waitforre <^> lineCommand("waitforre")

        let varStart = (symbol("var") <|> symbol("setvariable")) *> identifier
        let varEnd = (space.oneOrMore *> any).optional
        let variable = curry({ key, val in TokenValue.variable(key, val ?? "") }) <^> varStart <*> varEnd

        let braceLeft = TokenValue.token <^> symbolOnly("{", "{")
        let braceRight = TokenValue.token <^> symbolOnly("}", "}")

        let lineCommands =
            debug
            <|> debugLevel
            <|> deleteVar
            <|> echo
            <|> exit
            <|> goto
            <|> gosub
            <|> move
            <|> nextroom
            <|> pause
            <|> put
            <|> returnToken
            <|> save
            <|> send
            <|> shift
            <|> unvar
            <|> variable
            <|> wait
            <|> waitfor
            <|> waitforre

        let otherCommands =
            label
            <|> match
            <|> matchre
            <|> matchwait

        let thenToken = symbol("then") *> lineCommands

        let ifArg = stringInSensitive("if_") *> int
        let ifArgSingle = curry({num, val in TokenValue.ifArgSingle(num, val)}) <^> ifArg <*> (space.many *> thenToken)
        let ifArgMulti = TokenValue.ifArg <^> ifArg <* (space.oneOrMore <* stringInSensitive("then") <* space.many).optional <* space.many <* char("{") <* newline
        let ifArgMultiNeedsBrace = TokenValue.ifArgNeedsBrace <^> ifArg <* (space.oneOrMore <* stringInSensitive("then") <* space.many).optional <* newline

        let ifExp = symbol("if") *> noneOf([" then", "{", "\n"]).map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
        let ifSingle = curry({exp, val in TokenValue.ifSingle(exp, val)}) <^> ifExp <* space.many <*> thenToken

        let ifMulti = TokenValue.If <^> ifExp <* (space.oneOrMore <* stringInSensitive("then") <* space.many).optional <* char("{") <* newline
        let ifMultiNeedsBrace = TokenValue.ifNeedsBrace <^> ifExp <* (space.oneOrMore <* stringInSensitive("then")).optional <* newline

        let elseIf = symbol("else") *> ifExp
        let elseIfSingle = curry({exp, val in TokenValue.elseIfSingle(exp, val)}) <^> elseIf <*> (space.many *> thenToken)
        let elseIfMulti = TokenValue.elseIf <^> (symbol("else") *> ifExp <* (space.oneOrMore <* stringInSensitive("then") <* space.many).optional <* char("{") <* newline)
        let elseIfMultiNeedsBrace = TokenValue.elseIfNeedsBrace <^> (symbol("else") *> ifExp <* (space.oneOrMore <* stringInSensitive("then")).optional <* newline)

        let elseSingle = TokenValue.elseSingle <^> (symbol("else") *> space.many *> lineCommands)
        let elseMulti = TokenValue.Else <^^> stringInSensitive("else") <* space.many <* char("{") <* newline
        let elseMultiNeedsBrace = TokenValue.elseNeedsBrace <^^> stringInSensitive("else") <* newline

        let row = ws.many.optional *> (
            comment
            <|> lineCommands
            <|> otherCommands
            <|> ifArgSingle
            <|> ifArgMulti
            <|> ifArgMultiNeedsBrace
            <|> ifSingle
            <|> ifMulti
            <|> ifMultiNeedsBrace
            <|> elseIfSingle
            <|> elseIfMulti
            <|> elseIfMultiNeedsBrace
            <|> elseMulti
            <|> elseMultiNeedsBrace
            <|> elseSingle
            <|> braceLeft
            <|> braceRight
        ) <* ws.many.optional

        let actualInput = input.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) + "\n"
        let parseResult = row.run(actualInput)

        return parseResult?.0
    }

    public func char(_ c:Character) -> Parser<Character> {
        return character(condition: { $0 == c })
    }

    public func symbol(_ s:String) -> Parser<String> {
        return (stringInSensitive(s) <* space)
    }

    public func lineCommand(_ s:String) -> Parser<String> {
        let any = anyChar.many.map { String($0) }
        return ((symbol(s) *> any).map { $0.trimEnd(CharacterSet.whitespaces) }) <|> symbolOnly(s, "")
    }

    public func symbolOnly<A>(_ s:String, _ val:A) -> Parser<A> {
        return (stringInSensitive(s) *> newline *> Parser(result: val))
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

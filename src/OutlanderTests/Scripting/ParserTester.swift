//
//  ParserTester.swift
//  Outlander
//
//  Created by Joseph McBride on 7/13/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

enum LexToken {
    case openParen
    case closeParen
    case keyword(String)
    case text(String)
    case quotedText(String)
    case newline
    case error(String)
}

extension LexToken {
    static func lex(expr:String) -> [LexToken] {
        return LexTokenizer().tokenize(expr)
    }
}

class LexTokenizer {

    class LexerContext {
        internal var characters:ArraySlice<Character>
        internal var current:String
        internal var words:String

        internal var currentIndex = -1

        internal let length:Int

        internal var currentCharacter:Character {
            get {
//                guard currentIndex > -1 && currentIndex < characters.count else {
//                    return nil
//                }

                return characters[currentIndex]
            }
        }

        internal var combined:String {
            get {
                let space = self.current.characters.count > 0 ? " " : ""
                return "\(self.words)\(space)\(self.current)"
            }
        }

        init(_ characters:ArraySlice<Character>) {
            self.characters = characters
            self.length = characters.count
            self.current = ""
            self.words = ""
        }

        func advance() -> Bool {
            self.currentIndex += 1
            return self.currentIndex < self.length
        }

        func consume() {
            self.current.append(currentCharacter)
        }

        func consumeWord() {
            if self.words.characters.count > 0 {
                self.words += " "
            }

            self.words += self.current
            self.current = ""
        }

        func reset() {
            self.words = ""
            self.current = ""
        }

        func advanceTo(character:Character, include:Bool = false) -> Bool {
            while self.advance() {
                if self.currentCharacter == character {
                    if include {
                        self.consume()
                    }
                    return true
                }

                self.consume()
            }

            return false
        }
    }

    private let keywords = [
        "if",
        "if_",
        "echo",
        "else",
        "put",
        "then"
    ]

    func tokenize(sexpr:String) -> [LexToken] {
        return tokenize(ArraySlice<Character>(sexpr.characters))
    }

    func tokenize(sexpr: ArraySlice<Character>) -> [LexToken] {
        var res:[LexToken] = []
        let context = LexerContext(sexpr)

        while context.advance() {
            switch context.currentCharacter {
            case "(":
                res.append(.openParen)
                context.reset()
            case ")":
                res.append(.closeParen)
                context.reset()
            case " ":
                if keywords.contains(context.current) {
                    if context.words.characters.count > 0 {
                        res.append(.text(context.words))
                    }
                    res.append(.keyword(context.current))
                    context.reset()
                } else {
                    context.consumeWord()
                }
            case "\n":
                if keywords.contains(context.current) {
                    if context.words.characters.count > 0 {
                        res.append(.text(context.words))
                    }
                    res.append(.keyword(context.current))
                    context.reset()
                } else {
                    res.append(.text(context.combined))
                }
                res.append(.newline)
                context.reset()
            case "\"":
                guard context.advanceTo("\"") else {
                    return [.error("missing end quote")]
                }
                if context.current.characters.count > 0 {
                    res.append(.quotedText(context.current))
                }
                context.reset()
            default:
                context.consume()
            }
        }

        if context.combined.characters.count > 0 {
            if keywords.contains(context.current) {
                if context.words.characters.count > 0 {
                    res.append(.text(context.words))
                }
                res.append(.keyword(context.current))
            } else {
                res.append(.text(context.combined))
            }
        }

        return res
    }
}

class LexerTokenizerTester : QuickSpec {

    override func spec() {

        describe("lexer") {

            it("lexes put") {
                let tokens = LexToken.lex("put one two three four\n")
                print("\n")
                print(tokens)
                print("\n")
                expect(tokens.count).to(equal(3))
            }

            it("lexes if") {
                let tokens = LexToken.lex("if one two three then four\n")
                print("\n")
                print(tokens)
                print("\n")
                expect(tokens.count).to(equal(5))
            }

            it("lexes quoted string") {
                let tokens = LexToken.lex("if \"one two\" three\n")
                print("\n")
                print(tokens)
                print("\n")
                expect(tokens.count).to(equal(4))
            }

            it("lexes quoted string missing end") {
                let tokens = LexToken.lex("if \"one two three\n")
                print("\n")
                print(tokens)
                print("\n")
                expect(tokens.count).to(equal(1))
            }
        }
    }
}

////
////  OutlanderParser.swift
////  Outlander
////
////  Created by Joseph McBride on 3/24/17.
////  Copyright © 2017 Joe McBride. All rights reserved.
////
//
//import Foundation
//import SwiftParsec
//
//public enum TokenValue {
//
//    case label(String)
//    case put(String)
//    case error
//
//    public static let parser: GenericParser<String, String, TokenValue> = {
//        let lang = LanguageDefinition<String>.outlander
//        let lexer = GenericTokenParser(languageDefinition: lang)
//
//        let space = lexer.space
//        let character = StringParser.character
//        let symbol = lexer.symbol
//        let stringLiteral = lexer.stringLiteral
//        let identifier = lexer.identifier
//
//        let ostring = stringLiteral <|> identifier
//        let onumber = lexer.float.attempt <|> lexer.integerAsFloat
//
//        let label = TokenValue.label <^> identifier <* symbol(":")
//
//        let str = space *> ostring <* space
//
//        let put = TokenValue.put <^> (symbol("put") *> space *> ostring)
//
////        let label = identifier >>- { name in
////            .label(name) <* symbol(":")
////        }
//
////        let label: GenericParser<String, String, String> = identifier >>- { name in
////            return symbol(":") *> .label(name)
////        }
//
////        let trueValue = symbol("true") *> GenericParser(result: true)
////        let falseValue = symbol("false") *> GenericParser(result: false)
//
////        var command: GenericParser<String, (), TokenValue>!
//
////        GenericParser.recursive { (val: GenericParser<String, String, TokenValue>) in
////
////            return ostring <|> onumber
////        }
//
//        return lexer.whiteSpace *> (label <|> put) <* lexer.whiteSpace
//    }()
//
//    public var string: String? {
//
//        switch self {
//        case .label(let str):
//            return str
//        case .put(let str):
//            return str
//        default:
//            return nil
//        }
//    }
//}
//
//extension LanguageDefinition {
//    public static var outlander: LanguageDefinition<UserState> {
//
//        var def = LanguageDefinition<UserState>.empty
//
//        def.commentStart = "#"
//        def.isCaseSensitive = false
//        def.allowNestedComments = false
//
//        def.identifierStart = GenericParser.memberOf(identifierStartSet)
//
//        def.identifierLetter  = { char in
//
//            return GenericParser.memberOf(identifierLetterSet)
//        }
//
////        def.reservedOperators = [
////            "=", "->", "@", "#", "<", "&", "`", "?", ">", "!", "$"
////        ]
//
////        let opChars = ":!$%&*+/<=>?\\^|-~"
////
////        def.operatorStart = GenericParser.oneOf(opChars)
////        def.operatorLetter = GenericParser.oneOf(opChars)
//
//        return def
//    }
//
//}
//
//extension TokenParserType {
//
//    typealias CharacterParser = GenericParser<String, UserState, Character>
//
//    public var space: GenericParser<String, UserState, ()> {
//        let space = CharacterParser.satisfy({ $0.isSpace }).skipMany
//        return (space <?> "").skipMany
//    }
//}
//
//private let identifierStartCharacters =
//        (0x0041...0x005A).stringValue + // 'A' to 'Z'
//        (0x0061...0x007A).stringValue + // 'a' to 'z'
//        "_"
//
//private let identifierStartSet =
//    NSCharacterSet(charactersInString: identifierStartCharacters)
//
//private let identifierLetterCharacters =
//    identifierStartCharacters +
//        "0123456789" +
//        "." +
//        (0x0300...0x036F).stringValue +
//        (0x1DC0...0x1DFF).stringValue +
//        (0x20D0...0x20FF).stringValue +
//        (0xFE20...0xFE2F).stringValue
//
//private let identifierLetterSet =
//    NSCharacterSet(charactersInString: identifierLetterCharacters)
//
//extension SequenceType where Generator.Element == Int {
//
//    /// Converts each `Int` in its `Character` equivalent and build a String with the result.
//    var stringValue: String {
//
//        var chars = ContiguousArray<Character>()
//
//        for elem in self {
//
//            chars.append(Character(UnicodeScalar(elem)))
//
//        }
//
//        return String(chars)
//
//    }
//}

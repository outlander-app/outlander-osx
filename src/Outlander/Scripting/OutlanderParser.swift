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
//        let character = StringParser.character
//        let symbol = lexer.symbol
//        let stringLiteral = lexer.stringLiteral
//        let identifier = lexer.identifier
//
//        let ostring = stringLiteral <|> identifier
//        let onumber = lexer.float.attempt <|> lexer.integerAsFloat
//        let rest = lexer.whiteSpace *> lexer.characterLiteral.many
//
//        let label = TokenValue.label <^> identifier <* symbol(":")
//
//        let put = TokenValue.put <^> symbol("put") <*> rest
//
//        return lexer.whiteSpace *> (put) <* lexer.whiteSpace
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
//        def.identifierStart = GenericParser.memberOf(swiftIdentifierStartSet)
//
//        def.identifierLetter = { char in
//            return GenericParser.memberOf(swiftIdentifierLetterSet)
//        }
//
//        return def
//    }
//
//}
//
//private let swiftIdentifierStartCharacters =
//        (0x0041...0x005A).stringValue + // 'A' to 'Z'
//        (0x0061...0x007A).stringValue + // 'a' to 'z'
//        "_" +
//        "\u{00A8}\u{00AA}\u{00AD}\u{00AF}" +
//        (0x00B2...0x00B5).stringValue +
//        (0x00B7...0x00BA).stringValue +
//        (0x00BC...0x00BE).stringValue +
//        (0x00C0...0x00D6).stringValue +
//        (0x00D8...0x00F6).stringValue +
//        (0x00F8...0x00FF).stringValue +
//        (0x0100...0x02FF).stringValue +
//        (0x0370...0x167F).stringValue +
//        (0x1681...0x180D).stringValue +
//        (0x180F...0x1DBF).stringValue +
//        (0x1E00...0x1FFF).stringValue +
//        (0x200B...0x200D).stringValue +
//        (0x202A...0x202E).stringValue +
//        (0x203F...0x2040).stringValue +
//        "\u{2054}" +
//        (0x2060...0x206F).stringValue +
//        (0x2070...0x20CF).stringValue +
//        (0x2100...0x218F).stringValue +
//        (0x2460...0x24FF).stringValue +
//        (0x2776...0x2793).stringValue +
//        (0x2C00...0x2DFF).stringValue +
//        (0x2E80...0x2FFF).stringValue +
//        (0x3004...0x3007).stringValue +
//        (0x3021...0x302F).stringValue +
//        (0x3031...0x303F).stringValue +
//        (0x3040...0xD7FF).stringValue +
//        (0xF900...0xFD3D).stringValue +
//        (0xFD40...0xFDCF).stringValue +
//        (0xFDF0...0xFE1F).stringValue +
//        (0xFE30...0xFE44).stringValue +
//        (0xFE47...0xFFFD).stringValue +
//        (0x10000...0x1FFFD).stringValue +
//        (0x20000...0x2FFFD).stringValue +
//        (0x30000...0x3FFFD).stringValue +
//        (0x40000...0x4FFFD).stringValue +
//        (0x50000...0x5FFFD).stringValue +
//        (0x60000...0x6FFFD).stringValue +
//        (0x70000...0x7FFFD).stringValue +
//        (0x80000...0x8FFFD).stringValue +
//        (0x90000...0x9FFFD).stringValue +
//        (0xA0000...0xAFFFD).stringValue +
//        (0xB0000...0xBFFFD).stringValue +
//        (0xC0000...0xCFFFD).stringValue +
//        (0xD0000...0xDFFFD).stringValue +
//        (0xE0000...0xEFFFD).stringValue
//
//private let swiftIdentifierStartSet =
//    CharacterSet(charactersIn: swiftIdentifierStartCharacters)
//
//private let swiftIdentifierLetterCharacters =
//    swiftIdentifierStartCharacters +
//        "0123456789" +
//        "." +
//        (0x0300...0x036F).stringValue +
//        (0x1DC0...0x1DFF).stringValue +
//        (0x20D0...0x20FF).stringValue +
//        (0xFE20...0xFE2F).stringValue
//
//private let swiftIdentifierLetterSet =
//    CharacterSet(charactersIn: swiftIdentifierLetterCharacters)

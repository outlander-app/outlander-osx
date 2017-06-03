//
//  StreamTokenizer.swift
//  Outlander
//
//  Created by Joseph McBride on 6/2/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

enum StreamToken {
    case text(String)
    indirect case tag(String, [Attribute], [StreamToken])
}

struct Attribute {
    var key:String
    var value:String
}

class StreamTokenizer {

    let space = character(condition: { CharacterSet.whitespaces.contains($0.unicodeScalar) })
    let ws = character(condition: { CharacterSet.whitespacesAndNewlines.contains($0.unicodeScalar) })
    let newline = character(condition: { CharacterSet.newlines.contains($0.unicodeScalar) })

    let anyChar = character(condition: { !CharacterSet.newlines.contains($0.unicodeScalar) })

    let equal:Character = "="
    let leftTag:Character = "<"
    let rightTag:Character = ">"
    let spaceChar:Character = " "
    let slash:Character = "/"
    
    let notOpenTag = character(condition: { $0 != "<" })

    func tokenize(_ input:String) -> [StreamToken] {
        var tokens:[StreamToken] = []

        var hasMore = true
        var remainder = input.characters

        repeat {
            guard let result = parse(String(remainder)) else {
                hasMore = false
                continue
            }
            tokens.append(result.0)
            remainder = result.1

        } while hasMore

        return tokens
    }

    func parse(_ input:String) -> (StreamToken, String.CharacterView)? {

        if input.characters.count == 0 {
            return nil
        }
        
        let text = StreamToken.text <^> notOpenTag.many.map { String($0) }

        let name = noneOf([" ", "/>", ">"])
        let openTag = char(leftTag) *> name
        let selfCloseEndTag = string("/>")

        let attributeStart = space.many *> noneOf([equal, slash, rightTag]) <* char(equal)
        let attribute = Attribute.init <^> attributeStart <*> quote()

        let attributes = space.many *> attribute.many

        let selfClosingTag = curry({name, attrs in StreamToken.tag(name, attrs, []) }) <^> openTag <*> attributes <* selfCloseEndTag

        let endTag = string("</") *> name <* char(rightTag)

        let tagWithNoChild = curry({name, attrs in StreamToken.tag(name, attrs, []) }) <^> openTag <*> (attributes <* char(rightTag) <* endTag)
        
        let tagWithTextChild = curry({name, attrs, child in StreamToken.tag(name, attrs, [child]) }) <^> openTag <*> (attributes <* char(rightTag)) <*> (text <* endTag)

        let someTags = selfClosingTag <|> tagWithNoChild <|> tagWithTextChild

        let tagWithChildren = tag(someTags, openTag, attributes, endTag)
        let tagWithChildren2 = tag((someTags <|> tagWithChildren), openTag, attributes, endTag)

        let row = selfClosingTag <|> tagWithNoChild <|> tagWithTextChild <|> tagWithChildren2 <|> tagWithChildren <|> text

        var actualInput = handleNonEscapedQuotes(input)
        actualInput = actualInput.trimEnd(CharacterSet.newlines) + "\n"
        let parseResult = row.run(actualInput)
        return parseResult
    }

    public func quote() -> Parser<String> {
        return (block("\"", "\"") <|> block("'", "'"))
    }

    public func tag(
        _ child:Parser<StreamToken>,
        _ openTag:Parser<String>,
        _ attributes:Parser<[Attribute]>,
        _ endTag:Parser<String>) -> Parser<StreamToken> {

        let tag = curry({name, attrs, children in StreamToken.tag(name, attrs, children)}) <^> openTag <*> (attributes <* char(">")) <*> (child.many <* endTag)
        return tag
    }

    private func handleNonEscapedQuotes(_ input:String) -> String {
        var result = input

        let group = input["subtitle=\" - \\[(.*)\\]\""].firstGroup()
        if group.count > 1 {
            result = result.replace(group[1], withString: group[1].trim("\""))
        }
        
        return result
    }
}

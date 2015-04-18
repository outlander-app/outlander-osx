//
//  OutlanderStandard.swift
//  Scripter
//
//  Created by Joseph McBride on 11/16/14.
//  Copyright (c) 2014 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit

public class IfToken : BranchToken {
    
    public init(_ index:Int,_ lineNumber:Int){
        super.init("if", index, lineNumber)
    }
}

public class ElseIfToken : BranchToken {
    
    public init(_ index:Int,_ lineNumber:Int){
        super.init("elseif", index, lineNumber)
    }
}

public class BranchToken : CommandToken {
    
    public var expression = [Token]()
    public var argumentCheck:Int?
    public var lastResult:String?
    
    public override init(_ name:String, _ index:Int, _ lineNumber:Int){
        super.init(name, index, lineNumber);
    }
    
    public func expressionText() -> String {
    
        var text = ""
        
        for t in expression {
            text += t.characters
        }
    
        return text
    }
    
    public override var description : String {
        if (originalStringIndex != nil && originalStringLine != nil) {
            return "\(name) '\(self.expressionText())' at \(originalStringLine!),\(originalStringIndex!) "
        } else if (originalStringIndex != nil) {
            return "\(name) '\(self.expressionText())' at \(originalStringIndex!)"
        } else {
            return "\(name) '\(self.expressionText())'"
        }
    }
}

public class CommandToken : Token {
    
    public var body = [Token]()
    
    public init(_ name:String, _ index:Int, _ lineNumber:Int){
        super.init(name:name, withCharacters:"", index:index)
        self.originalStringLine = lineNumber
    }
    
    public func bodyText() -> String {
    
        var text = ""
        
        for t in body {
            text += t.characters
        }
    
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    public override var description : String {
        if (originalStringIndex != nil && originalStringLine != nil) {
            return "\(name) '\(self.bodyText())' at \(originalStringLine!),\(originalStringIndex!) "
        } else if (originalStringIndex != nil) {
            return "\(name) '\(self.bodyText())' at \(originalStringIndex!)"
        } else {
            return "\(name) '\(self.bodyText())'"
        }
    }
}

public class FuncToken : Token {
    
    public var body = [Token]()
    
    public init(_ name:String, _ index:Int, _ lineNumber:Int){
        super.init(name:name, withCharacters:"", index:index)
        self.originalStringLine = lineNumber
    }
    
    public func bodyText() -> String {
    
        var text = ""
        
        for t in body {
            text += t.characters
        }
    
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    public override var description : String {
        if (originalStringIndex != nil && originalStringLine != nil) {
            return "\(name) '\(self.bodyText())' at \(originalStringLine!),\(originalStringIndex!) "
        } else if (originalStringIndex != nil) {
            return "\(name) '\(self.bodyText())' at \(originalStringIndex!)"
        } else {
            return "\(name) '\(self.bodyText())'"
        }
    }
}

public class MatchReEvalToken : Token, EvalToken {
    
    var token:FuncToken
    var left:[Token]
    var right:[Token]
    
    public init(_ token:FuncToken) {
        self.token = token
        self.left = []
        self.right = []
        
        super.init(name: "matchre-func", withCharacters: "")
        
        var appendLeft = true
        
        for t in token.body {
            if t.name == "punct" && t.characters == "," {
                appendLeft = false
                continue
            }
            
            if appendLeft {
                left.append(t)
            } else {
                right.append(t)
            }
        }
    }
    
    public func eval(simplify: (Array<Token>)->String) -> (Bool, String) {
        let lh = simplify(left)
        let rh = simplify(right)
        
        var groups = lh[rh].groups()
        var found = groups.count > 0
        
        return (found, "matchre(\(lh), \(rh)) = \(found)")
    }
}

public class LabelToken : Token {
    public init(_ withCharacters:String, _ index:Int, _ lineNumber:Int){
        super.init(name:"label", withCharacters:withCharacters, index:index)
        self.originalStringLine = lineNumber
    }
}

public class CommentToken : Token {
    public init(_ withCharacters:String, _ index:Int, _ lineNumber:Int){
        super.init(name:"comment", withCharacters:withCharacters, index:index)
        self.originalStringLine = lineNumber
    }
}

public class OutlanderStandard {
    public class var word:TokenizationState{
        return LoopingCharacters(from: lowerCaseLetterString+upperCaseLetterString+decimalDigitString+"_-.").token("word")
    }
}

public class ScriptTokenizer : Tokenizer {
    
    public override init() {
        super.init();
        
        self.branch(
            OKStandard.whiteSpaces,
            Keywords(
                validStrings: ["action", "debuglevel", "echo", "else", "exit", "gosub", "goto", "if", "match", "matchre", "matchwait", "move", "nextroom", "pause", "put", "return", "shift", "send", "setvariable", "then", "var", "waitfor", "waitforre", "when", "#alias", "#highlight", "#script", "#parse", "#var"])
                .branch(
                    OutlanderStandard.word.token("variable"),
                    Exit().token("keyword")
            ),
            Keywords(validStrings:[">", "<", "=", "==", "!=", ">=", "<="]).branch(
                Exit().token("bool-operator")
            ),
            Keywords(validStrings:["|", "||", "&", "&&"]).branch(
                Exit().token("or-operator")
            ),
            Characters(from:"#").token("comment"),
            Characters(from:"\n").token("newline"),
            Characters(from:":").token("label"),
            Characters(from:";").token("split"),
            Characters(from:"(").token("open-paren"),
            Characters(from:")").token("close-paren"),
            Characters(from:"{").token("open-bracket"),
            Characters(from:"}").token("close-bracket"),
            Characters(from:"%").branch(
                OutlanderStandard.word.token("localvar")
            ),
            Characters(from:"$").branch(
                OutlanderStandard.word.token("globalvar")
            ),
            OKStandard.Code.quotedString,
            OKStandard.number,
            OKStandard.word,
            OKStandard.punctuation,
            OKStandard.eot
        )
    }
}

public class OutlanderScriptParser : StackParser {
    
    public var errors = [String]()
    
    var lineNumber = 0
    var comment = false
    var ifStack = [BranchToken]()
    
    var lineCommandStack = [String]()
    var lineCommands = ["debuglevel", "echo", "gosub", "goto", "match", "matchre", "matchwait", "move", "nextroom", "pause", "put", "return", "shift", "send", "setvariable", "var", "waitfor", "waitforre"]
    
    var validLabelTokens = ["globalvar", "variable", "localvar", "word", "keyword", "punct"]
   
    var funcCommandStack = [String]()
    var funcCommands = ["matchre"]
    
    public func parseString(string:String) -> Array<Token> {
        var str = string
        if !str.hasSuffix("\n") {
            str += "\n"
        }
        ScriptTokenizer().tokenize(str, parse)
        
        return super.tokens()
    }
    
    override public func parse(token: Token) -> Bool {
        
        token.originalStringLine = lineNumber
        
        if handleComment(token) {
            return true
        }
        
        switch token.name {
        case _ where token.name == "newline":
            lineNumber++
            endCommand()
        case _ where token.name == "keyword":
            // TODO: remove this once keyword bug is fixed (keyword matches partials)
            if(token.characters == "#") {
                createComment(token)
            }
            else if(token.characters == "if") {
                // if there is an elseif token on the stack, ignore this if
                if let lastToken = ifStack.last {
                    if lastToken.name == "elseif" {
                        break
                    }
                }
                let ifToken = IfToken(token.originalStringIndex!, token.originalStringLine!)
                pushToken(ifToken)
                ifStack.append(ifToken)
            }
            else if(token.characters == "else") {
                let elseToken = ElseIfToken(token.originalStringIndex!, token.originalStringLine!)
                pushToken(elseToken)
                ifStack.append(elseToken)
            }
            else if(token.characters == "then") {
                endIf()
            }
            else if lineCommandStack.count == 0 && contains(lineCommands, token.characters) {
                pushToken(CommandToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
                lineCommandStack.append(token.characters)
            }
            else {
                pushToken(token)
            }
        case _ where token.name == "variable":
            if token.characters.hasPrefix("if_") {
                let ifToken = IfToken(token.originalStringIndex!, token.originalStringLine!)
                let argStr = token.characters.substringFromIndex(advance(token.characters.startIndex, 3))
                ifToken.argumentCheck = argStr.toInt()
                pushToken(ifToken)
                ifStack.append(ifToken)
            }
            else if token.characters.hasPrefix("#") {
                createComment(token)
            }
            else {
                pushToken(token)
            }
        case _ where token.name == "open-paren":
            if let name = lineCommandStack.last where contains(self.funcCommands, name) {
                let command = lineCommandStack.removeLast()
                var tokens = popTo(command)
                let token = tokens.removeAtIndex(0) as! CommandToken
                
                pushToken(FuncToken(token.name, token.originalStringIndex!, token.originalStringLine!))
                funcCommandStack.append(token.name)
            } else {
                pushToken(token)
            }
        case _ where token.name == "close-paren":
            if funcCommandStack.count > 0 {
                
                let command = funcCommandStack.removeLast()
                var tokens = popTo(command)
                let token = tokens.removeAtIndex(0) as! FuncToken
                token.body = tokens
                pushToken(token)
            } else {
                pushToken(token)
            }
        case _ where token.name == "open-bracket":
            pushToken(token)
        case _ where token.name == "close-bracket":
            if !ifStack.isEmpty {
                endIfBody()
            }
        case _ where token.name == "label":
            createLabel(token)
        case _ where token.name == "comment":
            createComment(token)
        default:
            pushToken(token)
            return true
        }
        
        return true;
    }
    
    func createComment(token:Token) {
        endCommand()
        comment = true
        pushToken(CommentToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
    }
    
    func handleComment(token:Token) -> Bool {
        var handled = false
        if comment == true {
            handled = true
            if token.name == "newline" {
                lineNumber++
                endComment()
            } else {
                pushToken(token)
            }
        }
        return handled
    }
    
    func endComment() {
        var tokens = popTo("comment")
        let commentToken = tokens.removeAtIndex(0) as! CommentToken
        
        for token in tokens {
            commentToken.characters += token.characters
        }
        
        pushToken(commentToken)
        
        comment = false
    }
    
    func createLabel(token:Token) {
        var idx = -1
        var line = -1
        var chars = ""
        
        while topToken() != nil
            && topToken()!.originalStringLine == token.originalStringLine
            && contains(validLabelTokens, topToken()!.name) {
                
            let popped = popToken()!
            idx = popped.originalStringIndex!
            line = token.originalStringLine!
            chars = popped.characters + chars
        }
        
        if count(chars) > 0 {
            let labelToken = LabelToken(chars, idx, line)
            pushToken(labelToken)
        } else {
            errors.append("No matching label name. (\(token.originalStringIndex),\(lineNumber))")
        }
    }
    
    func endCommand() {
        if(lineCommandStack.isEmpty) {return}
        let command = lineCommandStack.removeLast()
        var tokens = popTo(command)
        let token = tokens.removeAtIndex(0) as! CommandToken
        token.body = tokens
        pushToken(token)
    }
    
    func endIf() {
        
        if ifStack.count == 0 {
            errors.append("Error matching beginning of if statement (\(lineNumber))")
            return
        }
        
        let stackToken = ifStack[ifStack.count - 1]
        var tokens = popTo(stackToken.name)
        let ifToken = tokens.removeAtIndex(0) as! BranchToken;
        ifToken.expression = tokens
        pushToken(ifToken)
    }
    
    func endIfBody() {
        endCommand()
        var tokens = popTo("open-bracket")
        tokens.removeAtIndex(0)
        let ifToken = ifStack.removeLast()
        ifToken.body = tokens
    }
    
    func popTo(tokenNamed:String)->Array<Token> {
        var tokenArray = Array<Token>()
        
        
        if !hasTokens() {
            errors.append("Failed to pop to \(tokenNamed), there were no tokens on the stack")
            return tokenArray
        }
        
        var token = popToken()
        
        while (token?.name != tokenNamed) {
            if let nextToken = token {
                tokenArray.append(nextToken)
            } else {
                errors.append("Stack exhausted before finding \(tokenNamed) token")
                return tokenArray.reverse()
            }
            token = popToken()
            if token == nil {
                errors.append("Stack exhausted before finding \(tokenNamed) token")
                return tokenArray.reverse()
            }
        }
        
        if token != nil {
            tokenArray.append(token!)
        }
        
        return tokenArray.reverse()
    }
}

public protocol EvalToken {
    func eval(simplify: (Array<Token>)->String) -> (Bool, String)
}

public class BoolExpressionToken : Token, EvalToken {
    
    var left:Array<Token>
    var right:Array<Token>
    var inverse = false
    
    public init(left:Array<Token>, withOperator:String, right:Array<Token>) {
        self.left = left
        self.right = right
        super.init(name:"bool-expression", withCharacters:withOperator)
    }
    
    public func eval(simplify: (Array<Token>)->String) -> (Bool, String) {
        var result = false
        let lh = simplify(left)
        let rh = simplify(right)
        
        let lhNum = lh.toDouble()
        let rhNum = rh.toDouble()
        
        if lhNum != nil && rhNum != nil {
            switch characters {
                case "!=":
                    result = lhNum != rhNum
                case "<=":
                    result = lhNum <= rhNum
                case ">=":
                    result = lhNum >= rhNum
                case ">":
                    result = lhNum > rhNum
                case "<":
                    result = lhNum < rhNum
                case "==", "=":
                    result = lhNum == rhNum
                default:
                    result = false
            }
            
        } else {
            switch characters {
                case "!=":
                    result = lh != rh
                case "<=":
                    result = lh <= rh
                case ">=":
                    result = lh >= rh
                case ">":
                    result = lh > rh
                case "<":
                    result = lh < rh
                case "==", "=":
                    result = lh == rh
                default:
                    result = false
            }
        }
        
        var text = "\(lh) \(characters) \(rh) (\(result))"
        
        return (result, text)
    }
}

public class OrExpressionToken : Token, EvalToken {
    
    var left:EvalToken
    var right:EvalToken
    var inverse = false
    
    public init(left:EvalToken, withOperator:String, right:EvalToken) {
        self.left = left
        self.right = right
        super.init(name:"or-expression", withCharacters:withOperator)
    }
    
    public func eval(simplify: (Array<Token>)->String) -> (Bool, String) {
        var result = false
        let (lh, lhTxt) = left.eval(simplify)
        let (rh, rhTxt) = right.eval(simplify)
        
        switch characters {
//            case "|":
//                result = lh | rh
            case "||":
                result = lh || rh
//            case "&":
//                result = lh & rh
            case "&&":
                result = lh && rh
            default:
                result = false
        }
        
        var text = "\(lhTxt) \(characters) \(rhTxt) = \(result)"
        
        return (result, text)
    }
}

public class EndToken : Token {
    public init() {
        super.init(name: "end", withCharacters: "")
    }
}

public class ExpressionEvaluator : StackParser {
    
    var boolStack = [BoolExpressionToken]()
    var orStack = [String]()
    
    public func eval(tokens:Array<Token>) -> (Bool, String) {
        func simplify(tokens:Array<Token>)->String {
            var text = ""
            
            for t in tokens {
                text += t.characters
            }
            
            return text
        }
        
        return self.eval(tokens, simplify)
    }
    
    public func eval(tokens:Array<Token>, _ simplify:(Array<Token>)->String) -> (Bool, String) {
        
        for token in tokens {
            parse(token)
        }
        
        parse(EndToken())
        
        var result = false
        var info = ""
        
        if let evalToken = topToken() as? EvalToken {
           (result, info) = evalToken.eval(simplify)
        }
        
        return (result, info)
    }
    
    override public func parse(token: Token) -> Bool {
        
        if let funcToken = token as? FuncToken {
            
            if funcToken.name == "matchre" {
                pushToken(MatchReEvalToken(funcToken))
            }
            
            return true
        }
        
        switch token.name {
        case "whitespace":
            return true
        case "bool-operator":
            processOperator(token)
        case "or-operator":
            processEnd()
            orStack.append(token.characters)
        case "open-paren":
            return true
        case "close-paren":
            return true
        case "end":
            processEnd()
        default:
            pushToken(token)
            return true
        }
        
        return true
    }
    
    func processOperator(token:Token) {
        
        var tokens = popTo("bool-expression", includeLast:false)
        
        var left = [Token]()
        var right = [Token]()
        
        for t in tokens {
            left.append(t)
        }
        
        var expr = BoolExpressionToken(left: left, withOperator: token.characters, right: right)
        pushToken(expr)
        boolStack.append(expr)
    }
    
    func processOrOperator(right:BoolExpressionToken) {
        boolStack.removeLast()
        
        var op = orStack.removeLast()
        
        var left = popToken() as! EvalToken
        
        var or = OrExpressionToken(left: left, withOperator: op, right: right)
        
        pushToken(or)
    }
    
    func processEnd() {
        
        var tokens = popTo("bool-expression", includeLast:false)
        if let expr = boolStack.last {
        
            for t in tokens {
                expr.right.append(t)
            }
            
            if(!orStack.isEmpty) {
                popToken()
                processOrOperator(expr)
            }
        }
        else {
            for t in tokens {
                pushToken(t)
            }
        }
    }
    
    func popTo(tokenNamed:String, includeLast:Bool)->Array<Token> {
        var tokenArray = Array<Token>()
        
        if !hasTokens() {
            return tokenArray
        }
        
        var token = topToken()
        
        while (token?.name != tokenNamed) {
            if let nextToken = token {
                tokenArray.append(nextToken)
                popToken()
            } else {
                break
            }
            token = topToken()
        }
        
        if token != nil && includeLast {
            tokenArray.append(token!)
            popToken()
        }
        
        return tokenArray.reverse()
    }
}

public class SimpleVarReplacer {
    public func eval(key:String, vars:Dictionary<String, String>) -> String {
        var result = key
        
        if count(key) > 1 {
            var checkKey = key.substringFromIndex(advance(key.startIndex, 1))
            if let val = vars[checkKey] {
                result = val
            }
        }
        return result
    }
}


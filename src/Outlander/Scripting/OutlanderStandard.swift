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
    public var lastResult:ExpressionEvalResult?
    
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
        return textForTokens(body)
    }
    
    public func textForTokens(tokens:[Token]) -> String {
        var text = ""
        
        for t in tokens {
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

public class IndexerToken : Token {
   
    var variable:String
    var indexer:String
    
    public init(_ characters:String, _ index:Int, _ lineNumber:Int){
        self.variable = ""
        self.indexer = ""
        
        super.init(name: "indexer", withCharacters:characters, index:index)
        self.originalStringLine = lineNumber
        
        let groups = characters["(.+)\\s*[\\(\\[]([\\$%\\w]+)"].groups()
        
        if groups.count > 2 {
            variable = groups[1]
            indexer = groups[2]
        }
    }
}

public class EvalCommandToken: CommandToken {
    
    public var variable = ""
    public var expression = [Token]()
    public var lastResult:ExpressionEvalResult?
    
    public init(_ index:Int, _ lineNumber:Int){
        super.init("eval", index, lineNumber);
    }
    
    func expressionText() -> String {
        
        var text = ""
        
        for (_, t) in expression.enumerate() {
            
            if t is CommandToken {
                let cmd = t as! CommandToken
                text +=  "\(cmd.name) \(cmd.bodyText())"
            }
            else {
                text += t.characters
            }
        }
    
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
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

public enum ActionToggle {
    case On
    case Off
}

public class ActionToken : CommandToken {
    
    public var commands = [Token]()
    public var when = [Token]()
    public var whenText = ""
    public var className = ""
    public var actionToggle:ActionToggle?
    
    public init(_ index:Int, _ lineNumber:Int){
        super.init("action", index, lineNumber);
    }
    
    public func commandText() -> String {
    
        var text = ""
        
        for (index, t) in commands.enumerate() {
            
            if index > 0 {
                text += ";"
            }
            
            if t is CommandToken {
                let cmd = t as! CommandToken
                text +=  "\(cmd.name) \(cmd.bodyText())"
            }
            else {
                text += t.characters
            }
        }
    
        return text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
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

public class MatchReEvalToken : FuncEvalToken {
    
    public init(_ token:FuncToken) {
        super.init("matchre-func", token)
    }
    
    override public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        
        super.eval(context, simplify: simplify)
        
        var lh = stack.count > 0 ? simplify(stack[0]) : ""
        var rh = stack.count > 1 ? simplify(stack[1]) : ""
        
        lh = lh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        rh = rh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        
        let groups = lh[rh].groups()
        let found = groups.count > 0
        
        return ExpressionEvalResult(
            result: EvalResult.Boolean(val: found),
            info: "matchre(\(lh), \(rh)) = \(found)",
            matchGroups: groups)
    }
}

public class CountSplitEvalToken : FuncEvalToken {
    
    public init(_ token:FuncToken) {
        super.init("countsplit-func", token)
    }
    
    override public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        
        super.eval(context, simplify: simplify)
        
        var lh = stack.count > 0 ? simplify(stack[0]) : ""
        var rh = stack.count > 1 ? simplify(stack[1]) : ""
        
        lh = lh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        rh = rh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        
        let count = lh.componentsSeparatedByString(rh).count
        
        return ExpressionEvalResult(result: EvalResult.Str(val: "\(count)"), info: "countsplit(\(lh), \(rh)) = \(count)", matchGroups:nil)
    }
}

public class DefEvalToken : FuncEvalToken {
    
    public init(_ token:FuncToken) {
        super.init("def-func", token)
    }
    
    override public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        super.eval(context, simplify: simplify)
        
        let lh = stack.count > 0 ? simplify(stack[0]) : ""
        let res = false
        
        return ExpressionEvalResult(result: EvalResult.Boolean(val: res), info: "def(\(lh)) = \(res)", matchGroups:nil)
    }
}

public class ContainsEvalToken : FuncEvalToken {
    
    public init(_ token:FuncToken) {
        super.init("contains-func", token)
    }
    
    override public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        
        super.eval(context, simplify: simplify)
        
        var lh = stack.count > 0 ? simplify(stack[0]) : ""
        var rh = stack.count > 1 ? simplify(stack[1]) : ""
        
        lh = lh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        rh = rh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        
        let contains = lh.containsString(rh)
        
        return ExpressionEvalResult(result: EvalResult.Boolean(val: contains), info: "contains(\(lh), \(rh)) = \(contains)", matchGroups:nil)
    }
}

public class ReplaceReEvalToken : FuncEvalToken {
    
    public init(_ token:FuncToken) {
        super.init("replacere-func", token)
    }
    
    override public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        
        super.eval(context, simplify: simplify)
        
        var lh = stack.count > 0 ? simplify(stack[0]) : ""
        var rh = stack.count > 1 ? simplify(stack[1]) : ""
        var replace = stack.count > 2 ? context.simplifyEach(stack[2]) : ""
        
        lh = lh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        rh = rh.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        replace = replace.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "\"'"))
        
        let mutable = RegexMutable(lh)
        let groups = mutable[rh].groups()
        mutable[rh] ~= replace
        
        let result = String(mutable)
        
        return ExpressionEvalResult(
            result: EvalResult.Str(val: result),
            info: "replacere(\(lh), \(rh), \(replace)) = \(result)",
            matchGroups:groups
        )
    }
}

public class FuncEvalToken : Token, EvalToken {
    
    var token:FuncToken
    var stack:[[Token]] = []
    
    public init(_ name:String, _ token:FuncToken) {
        self.token = token
        
        super.init(name: name, withCharacters: "")
        
        var current:[Token] = []
        
        for t in token.body {
            if t.name == "punct" && t.characters == "," {
                stack.append(current)
                current = []
                continue
            }
            
            if current.count == 0 && t.name == "whitespace" {
                continue
            }
            
            current.append(t)
        }
        
        stack.append(current)
    }
    
    public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        return ExpressionEvalResult(result: EvalResult.Boolean(val: false), info: "\(self.name) - not implemented", matchGroups:nil)
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

public class HexColorState : TokenizationState {
    let allowedCharacters : String
    
    public init(from:String){
        self.allowedCharacters = from
        super.init()
    }
    
    public override func scan(operation: TokenizeOperation){
        operation.debug("Entered HexColorState '\(allowedCharacters)'")
        
        if isAllowed(operation.current) {
            //Scan through as much as we can
            repeat {
                print("HexColorState: '\(operation.current)' '\(operation.context.consumedCharacters)'")
                operation.advance()
            } while !operation.complete && isAllowed(operation.current) && operation.context.consumedCharacters.characters.count < 8
            
            //Emit a token, branch on
            if operation.context.consumedCharacters.characters.count == 7 {
                emitToken(operation)
            }
            
            //If we are done, bug out
            if operation.complete {
                return
            }
            
            if operation.context.consumedCharacters.characters.count > 0 {
                scanBranches(operation)
            }
        }
    }
    
    func isAllowed(character:Character)->Bool{
        for allowedCharacter in allowedCharacters.characters {
            if allowedCharacter == character {
                return true
            }
        }
        return false
    }
}

public class Comments : TokenizationState{
    
    override public func stateClassName()->String {
        return "Comment"
    }
    
    public override func scan(operation: TokenizeOperation) {
        operation.debug("Entered Comment Char")
        
        if operation.current == "#" || operation.context.consumedCharacters.hasPrefix("#") {
            
            if operation.current == "#" {
                //Move scanning forward
                operation.advance()
            }
            
            //Emit a token, branch on
            emitToken(operation)
            
            //If we are done, bug out
            if operation.complete {
                return
            }
            
            //Otherwise evaluate our branches
            scanBranches(operation)
        }
    }
}

public class OutlanderStandard {
    public class var word:TokenizationState {
        return LoopingCharacters(from: lowerCaseLetterString+upperCaseLetterString+decimalDigitString+"$%_-.").token("word")
    }
    
    public class var localVar:TokenizationState {
        return Characters(from:"%").branch(
            OutlanderStandard.word.token("localvar")
        )
    }
    
    public class var hexColor:TokenizationState {
        let hexDigits = HexColorState(from: hexDigitString)
        return Characters(from:"#").branch(
            hexDigits.token("color").branch(
                IgnoreCaseKeywords(
                    validStrings: ["#alias", "#beep", "#echo", "#highlight", "#flash", "#goto", "#mapper", "#script", "#parse", "#var"])
                    .token("keyword").branch(
                        OutlanderStandard.word.token("variable"),
                        Exit().token("keyword")
                ),
                Exit().token("comment")
            ),
            Exit().token("comment")
        )
    }
    
    public class var comments:TokenizationState {
        return Comments().token("comment")
    }

    public class var indexer:TokenizationState {
       
        let prefix = LoopingCharacters(from:"%$")
        let word = LoopingCharacters(from: lowerCaseLetterString+upperCaseLetterString+decimalDigitString+"$%_-.")
        let leftParen = Characters(from:"(")
        let rightParen = Characters(from:")")
        let leftBracket = Characters(from:"[")
        let rightBracket = Characters(from:"]")
        let decimalDigits = LoopingCharacters(from:decimalDigitString)
        
        let parens =
            leftParen.clone().branch(
                decimalDigits.branch(
                    rightParen.clone().token("indexer")
                ),
                word.clone().branch(
                    rightParen.clone().token("indexer")
                )
            )
        
        let brackets =
            leftBracket.clone().branch(
                decimalDigits.branch(
                    rightBracket.clone().token("indexer")
                ),
                word.clone().branch(
                    rightBracket.clone().token("indexer")
                )
            )
    
        return Branch().branch(
            prefix.clone().branch( word.clone().branch(
                    parens.clone(),
                    brackets.clone(),
                    Exit().token("globalvar")
                ),
                Exit().token("punct")
            )
        )
    }
    
    public class var quotedString:TokenizationState {
        let charToken = "trn\"\\()^$Az.sSdDwWb?*+{}[]"
        let delem1 = "\""
        let delem2 = "\\"
        let delem3 = "\"\\"

        let repeater = Branch().branch(
            Characters(from:delem2).branch(
                // include regex escapes
                Characters(from:charToken).token("char")
            ), LoopingCharacters(except: delem3).token("char")
        )

        return Delimited(delimiter: delem1, states:
            Repeat(state: repeater, min: 1, max: nil).token("quoted-string")
        )
    }
}

public class ScriptTokenizer : Tokenizer {
    
    public override init() {
        super.init();
        
        self.branch(
            Characters(from:"\n").token("newline"),
            Characters(from:"\r\n").token("newline"),
            OKStandard.whiteSpaces,
            OutlanderStandard.hexColor,
            IgnoreCaseKeywords(
                validStrings: ["action", "contains", "countsplit", "debug", "debuglevel", "def", "echo", "else", "eval", "exit", "gosub", "goto", "if", "include", "match", "matchre", "matchwait", "math", "move", "nextroom", "pause", "put", "random", "replace", "replacere", "return", "save", "shift", "send", "setvariable", "then", "unvar", "var", "wait", "waiteval", "waitfor", "waitforre", "when", "#alias", "#beep", "#echo", "#highlight", "#flash", "#goto", "#mapper", "#script", "#parse", "#var"])
                .token("keyword").branch(
                    OutlanderStandard.word.token("variable"),
                    Exit().token("keyword")
                ),
            Keywords(validStrings:[">", "<", "=", "==", "!=", ">=", "<="]).branch(
                Exit().token("bool-operator")
            ),
            Keywords(validStrings:["|", "||", "&", "&&"]).branch(
                Exit().token("or-operator")
            ),
            OutlanderStandard.comments,
            Characters(from:":").token("label"),
            Characters(from:";").token("split"),
            OutlanderStandard.indexer,
            Characters(from:"(").token("open-paren"),
            Characters(from:")").token("close-paren"),
            Characters(from:"{").token("open-bracket"),
            Characters(from:"}").token("close-bracket"),
            OutlanderStandard.quotedString,
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
    var trackingExpression = false
    var inBracketCount = 0
    
    var lineCommandStack = [String]()
    var lineCommands = ["action", "debug", "debuglevel", "echo", "eval", "exit", "gosub", "goto", "include", "match", "matchre", "matchwait", "math", "move", "nextroom", "pause", "put", "random", "return", "save", "shift", "send", "setvariable", "unvar", "var", "wait", "waiteval", "waitfor", "waitforre"]
    
    var validLabelTokens = ["globalvar", "variable", "localvar", "word", "keyword", "integer", "punct"]
   
    var funcCommandStack = [String]()
    var funcCommands = ["contains", "countsplit", "def", "matchre", "replace", "replacere"]
    
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
            lineNumber += 1
            endCommand(true)
        case _ where token.name == "keyword":
            if(token.characters.lowercaseString == "if" && lineCommandStack.count == 0) {
                // if there is an elseif token on the stack, ignore this if
                if let lastToken = ifStack.last {
                    if lastToken.name == "elseif" {
                        break
                    }
                }
                let ifToken = IfToken(token.originalStringIndex!, token.originalStringLine!)
                pushToken(ifToken)
                ifStack.append(ifToken)
                self.trackingExpression = true
            }
            else if(token.characters.lowercaseString == "else" && lineCommandStack.count == 0) {
                let elseToken = ElseIfToken(token.originalStringIndex!, token.originalStringLine!)
                pushToken(elseToken)
                ifStack.append(elseToken)
            }
            else if(token.characters.lowercaseString == "then" && lineCommandStack.count == 0) {
                endIf()
                self.trackingExpression = false
            }
            else if lineCommandStack.count == 0 && lineCommands.contains(token.characters) {
                pushToken(CommandToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
                lineCommandStack.append(token.characters)
            }
            else if funcCommandStack.count == 0 && funcCommands.contains(token.characters){
                pushToken(FuncToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
                funcCommandStack.append(token.characters)
            }
            else {
                pushToken(token)
            }
        case _ where token.name == "variable":
            if token.characters.lowercaseString.hasPrefix("if_") {
                let ifToken = IfToken(token.originalStringIndex!, token.originalStringLine!)
                let argStr = token.characters.substringFromIndex(token.characters.startIndex.advancedBy(3))
                ifToken.argumentCheck = Int(argStr)
                pushToken(ifToken)
                ifStack.append(ifToken)
            }
            else {
                pushToken(token)
            }
        case _ where token.name == "open-paren":
            if let name = lineCommandStack.last where self.funcCommands.contains(name) {
                
                var isFunc = true
                
                // check if all previous tokens are whitespaces
                self.checkStackTo(name, check: { (token:Token?) -> Bool in
                    if let t = token where t.name != "whitespace" {
                        isFunc = false
                        return true
                    }
                    
                    return false
                })
                
                if isFunc {
                    let command = lineCommandStack.removeLast()
                    var tokens = popTo(command)
                    let token = tokens.removeAtIndex(0) as! CommandToken
                    
                    pushToken(FuncToken(token.name, token.originalStringIndex!, token.originalStringLine!))
                    funcCommandStack.append(token.name)
                } else {
                    pushToken(token)
                }
            } else if funcCommandStack.count == 0 {
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
            if self.trackingExpression {
                endIf()
                self.trackingExpression = false
            }
            self.inBracketCount = self.inBracketCount + 1
            pushToken(token)
        case _ where token.name == "close-bracket":
            if !ifStack.isEmpty {
                endIfBody()
            }
            else if lineCommandStack.count > 0 {
                pushToken(token)
            }
            self.inBracketCount = self.inBracketCount - 1
        case _ where token.name == "label":
            if lineCommandStack.count == 0 {
                createLabel(token)
            } else {
                pushToken(token)
            }
        case _ where token.name == "comment":
            if lineCommandStack.count == 0 {
                createComment(token)
            } else {
                pushToken(token)
            }
        case _ where token.name == "indexer":
            createIndexer(token)
        default:
            pushToken(token)
            return true
        }
        
        return true;
    }
    
    func createComment(token:Token) {
        endCommand(false)
        pushToken(CommentToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
        comment = true
    }
    
    func handleComment(token:Token) -> Bool {
        var handled = false
        if comment == true {
            handled = true
            if token.name == "newline" {
                lineNumber = lineNumber + 1
                endComment()
            } else {
                pushToken(token)
            }
        }
        return handled
    }
    
    func endComment() {
        var tokens =  popToType(CommentToken("", 0, 0))
        
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
            && validLabelTokens.contains(topToken()!.name) {
                
            let popped = popToken()!
            idx = popped.originalStringIndex!
            line = token.originalStringLine!
            chars = popped.characters + chars
        }
        
        if chars.characters.count > 0 {
            let labelToken = LabelToken(chars, idx, line)
            pushToken(labelToken)
        } else {
            errors.append("No matching label name. (\(token.originalStringIndex),\(lineNumber))")
        }
    }
    
    func createIndexer(token:Token) {
        let indexer = IndexerToken(token.characters, token.originalStringIndex!, token.originalStringLine!)
        pushToken(indexer)
    }
    
    func endCommand(newLine:Bool) {
        if(lineCommandStack.isEmpty) {return}
        let command = lineCommandStack.removeLast()
        var tokens = popTo(command)
        var token = tokens.removeAtIndex(0) as! CommandToken
        token.body = tokens
        
        if token.name == "action" {
            token = createAction(token)
        }
        
        if token.name == "eval" {
            token = createEval(token)
        }
        
        pushToken(token)
        
        if newLine && !(self.inBracketCount > 0) && ifStack.count > 0 {
            endIfBodyOneLine()
        }
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
    
    func endIfBodyOneLine() {
        let ifToken = ifStack.removeLast()
        
        var tokens = popTo(ifToken.name)
        tokens.removeAtIndex(0)
        
        ifToken.body = tokens
        
        pushToken(ifToken)
    }
    
    func endIfBody() {
        endCommand(false)
        var tokens = popTo("open-bracket")
        tokens.removeAtIndex(0)
        let ifToken = ifStack.removeLast()
        ifToken.body = tokens
    }
    
    func popToType<T : Token>(type:T) -> [Token] {
        var tokenArray = [Token]()
        
        if !hasTokens() {
            errors.append("Failed to pop to \(T.self), there were no tokens on the stack")
            return tokenArray
        }
        
        var token = popToken()
        
        while !(token is T) {
            if let nextToken = token {
                tokenArray.append(nextToken)
            } else {
                errors.append("Stack exhausted before finding '\(T.self)' token")
                return tokenArray.reverse()
            }
            token = popToken()
            if token == nil {
                errors.append("Stack exhausted before finding '\(T.self)' token")
                return tokenArray.reverse()
            }
        }
        
        if token != nil {
            tokenArray.append(token!)
        }
        
        return tokenArray.reverse()
    }
    
    func popTo(tokenNamed:String)->[Token] {
        var tokenArray = [Token]()
        
        if !hasTokens() {
            errors.append("Failed to pop to \(tokenNamed), there were no tokens on the stack")
            return tokenArray
        }
        
        var token = popToken()
        
        while (token?.name != tokenNamed) {
            if let nextToken = token {
                tokenArray.append(nextToken)
            } else {
                errors.append("Stack exhausted before finding '\(tokenNamed)' token")
                return tokenArray.reverse()
            }
            token = popToken()
            if token == nil {
                errors.append("Stack exhausted before finding '\(tokenNamed)' token")
                return tokenArray.reverse()
            }
        }
        
        if token != nil {
            tokenArray.append(token!)
        }
        
        return tokenArray.reverse()
    }
    
    func checkStackTo(tokenNamed:String, check:(Token?)->Bool) {
        
        var tokens = self.tokens()
        let end = tokens.count
        
        var last:Token?
        var current = end-1
        
        while current > -1 && last?.name != tokenNamed {
            last = tokens[current]
            
            if last?.name == tokenNamed {
                return
            }
            
            if check(last) {
                break
            }
            current = current - 1
        }
    }
    
    func createEval(token:CommandToken) -> CommandToken {
        let evalToken = EvalCommandToken(token.originalStringIndex!, token.originalStringLine!)
        evalToken.body = token.body
        
        var foundVar = false
        var inExpression = false
        
        for (_, t) in token.body.enumerate() {
            if (t.name == "keyword" || t.name == "word" || t.name == "variable" || t.name == "globalvar") && !foundVar && !inExpression {
                evalToken.variable = t.characters
                foundVar = true
            } else if (foundVar || inExpression || t is FuncToken) && t.name != "close-paren" {
                evalToken.expression.append(t)
            }
            
            if t.name == "open-paren" {
                inExpression = true
            }
        }
        
        return evalToken
    }
    
    func createAction(token:CommandToken) -> ActionToken {
        let actionToken = ActionToken(token.originalStringIndex!, token.originalStringLine!)
        actionToken.body = token.body
        
        var action = [Token]()
        
        var pastWhen = false
        var evalToken:CommandToken?
        
        for t in token.body {
            
            if t.name == "keyword" && t.characters == "when" {
                pastWhen = true
                continue
            }
            
            if t.name == "keyword" && t.characters == "eval" {
                evalToken = CommandToken("eval", t.originalStringIndex!, t.originalStringLine!)
                continue
            }
            
            if !pastWhen {
                
                if t.name == "close-paren" {
                    actionToken.className = token.textForTokens(action.filter{$0.name != "open-paren"})
                    action = []
                } else {
                    action.append(t)
                }
            } else {
                if evalToken != nil {
                    evalToken?.body.append(t)
                }
                else {
                    actionToken.when.append(t)
                }
            }
        }
        
        let actionText = token.textForTokens(action)
        
        let manageActions = ["on", "off"]
        
        if !pastWhen && !manageActions.contains(actionText) {
            errors.append("No when pattern defined for action on line \(token.originalStringLine!+1)")
        }
        
        if manageActions.contains(actionText) {
            switch actionText {
            case _ where actionText == "on":
                actionToken.actionToggle = ActionToggle.On
                
            default:
                actionToken.actionToggle = ActionToggle.Off
            }
        }
        
        if let evToken = evalToken {
            actionToken.when.append(createEval(evToken))
        } else {
            actionToken.whenText = token.textForTokens(actionToken.when)
        }
        
        var cmd:CommandToken?
        
        for t in action {
            
            if cmd == nil && t.name == "whitespace" {
                continue
            }
            
            if cmd == nil {
                cmd = CommandToken(t.characters, t.originalStringIndex!, t.originalStringLine!)
            } else if t.name == "split" {
                actionToken.commands.append(cmd!)
                cmd = nil
                continue
            } else {
                cmd?.body.append(t)
            }
        }
        
        if cmd != nil {
            actionToken.commands.append(cmd!)
        }
        
        return actionToken
    }
}

public protocol EvalToken {
    func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult
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
    
    public func eval(context: ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        var result = false
        let lh = simplify(left)
        let rh = simplify(right)
        
        let lhNum = lh.toDouble()
        let rhNum = rh.toDouble()
        
        if lhNum != nil && rhNum != nil {
            switch characters {
                case _ where characters == "!=":
                    result = lhNum != rhNum
                case  _ where characters == "<=":
                    result = lhNum <= rhNum
                case _ where characters == ">=":
                    result = lhNum >= rhNum
                case  _ where characters == ">":
                    result = lhNum > rhNum
                case _ where characters == "<":
                    result = lhNum < rhNum
                case _ where characters == "==", _ where characters == "=":
                    result = lhNum == rhNum
                default:
                    result = false
            }
            
        } else {
            switch characters {
                case _ where characters == "!":
                    if let val = rh.toBool() {
                        result = !val
                    }
                case _ where characters == "!=":
                    result = lh != rh
                case _ where characters == "<=":
                    result = lh <= rh
                case _ where characters == ">=":
                    result = lh >= rh
                case _ where characters == ">":
                    result = lh > rh
                case _ where characters == "<":
                    result = lh < rh
                case _ where characters == "==", _ where characters == "=":
                    result = lh == rh
                default:
                    result = false
            }
        }
        
        if inverse {
            result = !result
        }
        
        let text = "\(lh) \(characters) \(rh) (\(result))"
        
        return ExpressionEvalResult(result: EvalResult.Boolean(val: result), info:text, matchGroups:nil)
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
    
    public func eval(context:ScriptContext, simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        var result = false
        let lhRes = left.eval(context, simplify: simplify)
        let rhRes = right.eval(context, simplify: simplify)
        
        let lh = getBoolResult(lhRes.result)
        let rh = getBoolResult(rhRes.result)
        
        switch characters {
            case _ where characters == "||":
                result = lh || rh
            case _ where characters == "&&":
                result = lh && rh
            default:
                result = false
        }
        
        if inverse {
            result = !result
        }
        
        let text = "\(lhRes.info) \(characters) \(rhRes.info) = \(result)"
        
        return ExpressionEvalResult(result: EvalResult.Boolean(val: result), info:text, matchGroups:nil)
    }
    
    private func getBoolResult(result:EvalResult) -> Bool {
        switch(result) {
        case .Boolean(let x):
            return x
        default:
            return false
        }
    }
}

public class EndToken : Token {
    public init() {
        super.init(name: "end", withCharacters: "")
    }
}

public enum EvalResult {
    case Boolean(val:Bool)
    case Str(val:String)
}

public struct ExpressionEvalResult {
    var result:EvalResult
    var info:String
    var matchGroups:[String]?
}

public class ExpressionEvaluator : StackParser {
    
    var boolStack = [BoolExpressionToken]()
    var orStack = [String]()
    var inverse = false
    
    public func eval(context:ScriptContext, tokens:Array<Token>) -> ExpressionEvalResult {
        func simplify(tokens:Array<Token>)->String {
            var text = ""
            
            for t in tokens {
                text += t.characters
            }
            
            return text
        }
        
        return self.eval(context, tokens, simplify)
    }
    
    public func eval(context:ScriptContext, _ tokens:Array<Token>, _ simplify:(Array<Token>)->String) -> ExpressionEvalResult {
        
        for token in tokens {
            if token.name == "bool-operator" && token.characters == "!" {
                inverse = true
                continue
            }
            parse(token)
        }
        
        parse(EndToken())
        
        if let evalToken = topToken() as? EvalToken {
            var result = evalToken.eval(context, simplify: simplify)
            if inverse {
                result.result = EvalResult.Boolean(val: !getBoolResult(result.result))
            }
            return result
        }
        
        return ExpressionEvalResult(result:EvalResult.Boolean(val: false), info:"", matchGroups:nil)
    }
    
    override public func parse(token: Token) -> Bool {
        
        if let funcToken = token as? FuncToken {
            
            if funcToken.name == "contains" {
                pushToken(ContainsEvalToken(funcToken))
            }
            else if funcToken.name == "replacere" {
                pushToken(ReplaceReEvalToken(funcToken))
            }
            else if funcToken.name == "matchre" {
                pushToken(MatchReEvalToken(funcToken))
            }
            else if funcToken.name == "countsplit" {
                pushToken(CountSplitEvalToken(funcToken))
            }
            else if funcToken.name == "def" {
                pushToken(DefEvalToken(funcToken))
            }
            
            return true
        }
        
        if let evalToken = token as? EvalCommandToken {
            for t in evalToken.expression {
                self.parse(t)
            }
            return true
        }
        
        switch token.name {
        case _ where token.name == "whitespace":
            return true
        case _ where token.name == "bool-operator":
            processOperator(token)
        case _ where token.name == "or-operator":
            processEnd()
            orStack.append(token.characters)
        case _ where token.name == "open-paren":
            return true
        case _ where token.name == "close-paren":
            return true
        case _ where token.name == "end":
            processEnd()
        default:
            pushToken(token)
            return true
        }
        
        return true
    }
    
    private func getBoolResult(result:EvalResult) -> Bool {
        switch(result) {
        case .Boolean(let x):
            return x
        default:
            return false
        }
    }
    
    func processOperator(token:Token) {
        
        let tokens = popTo("bool-expression", includeLast:false)
        
        var left = [Token]()
        let right = [Token]()
        
        for t in tokens {
            left.append(t)
        }
        
        let expr = BoolExpressionToken(left: left, withOperator: token.characters, right: right)
        pushToken(expr)
        boolStack.append(expr)
    }
    
    func processOrOperator(right:BoolExpressionToken) {
        boolStack.removeLast()
        
        let op = orStack.removeLast()
        
        let left = popToken() as? EvalToken
        
        if let lh = left {
        
            let or = OrExpressionToken(left: lh, withOperator: op, right: right)
            
            pushToken(or)
        }
    }
    
    func processEnd() {
        
        let tokens = popTo("bool-expression", includeLast:false)
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

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
    var indexer:Int
    
    public init(_ characters:String, _ index:Int, _ lineNumber:Int){
        self.variable = ""
        self.indexer = -1
        
        super.init(name: "indexer", withCharacters:characters, index:index)
        self.originalStringLine = lineNumber
        
        let groups = characters["(.+)\\s*[\\(\\[](\\d+)"].groups()
        
        if groups.count > 2 {
            variable = groups[1]
            indexer = groups[2].toInt() ?? -1
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
        
        for (index, t) in enumerate(expression) {
            
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
        
        for (index, t) in enumerate(commands) {
            
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
    
    override public func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        let lh = simplify(left)
        let rh = simplify(right)
        
        var groups = lh[rh].groups()
        var found = groups.count > 0
        
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
    
    override public func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        let lh = simplify(left)
        let rh = simplify(right)
        
        let count = lh.componentsSeparatedByString(rh).count
        
        return ExpressionEvalResult(result: EvalResult.Str(val: "\(count)"), info: "countsplit(\(lh), \(rh)) = \(count)", matchGroups:nil)
    }
}

public class DefEvalToken : FuncEvalToken {
    
    public init(_ token:FuncToken) {
        super.init("def-func", token)
    }
    
    override public func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        let lh = simplify(left)
        let res = false
        
        return ExpressionEvalResult(result: EvalResult.Boolean(val: res), info: "def(\(lh)) = \(res)", matchGroups:nil)
    }
}

public class FuncEvalToken : Token, EvalToken {
    
    var token:FuncToken
    var left:[Token]
    var right:[Token]
    
    public init(_ name:String, _ token:FuncToken) {
        self.token = token
        self.left = []
        self.right = []
        
        super.init(name: name, withCharacters: "")
        
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
    
    public func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult {
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

public class OutlanderStandard {
    public class var word:TokenizationState {
        return LoopingCharacters(from: lowerCaseLetterString+upperCaseLetterString+decimalDigitString+"$%_-.").token("word")
    }
    
    public class var localVar:TokenizationState {
        return Characters(from:"%").branch(
            OutlanderStandard.word.token("localvar")
        )
    }
    
    public class var indexer:TokenizationState {
       
        var prefix = LoopingCharacters(from:"%$")
        var word = LoopingCharacters(from: lowerCaseLetterString+upperCaseLetterString+decimalDigitString+"$%_-.")
        let leftParen = Characters(from:"(")
        let rightParen = Characters(from:")")
        let leftBracket = Characters(from:"[")
        let rightBracket = Characters(from:"]")
        let decimalDigits = LoopingCharacters(from:decimalDigitString)
        
        let parens =
            leftParen.clone().branch(
                decimalDigits.branch(
                    rightParen.clone().token("indexer")
                )
            )
        
        let brackets =
            leftBracket.clone().branch(
                decimalDigits.branch(
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
}

public class ScriptTokenizer : Tokenizer {
    
    public override init() {
        super.init();
        
        self.branch(
            Keywords(
                validStrings: ["action", "countsplit", "debug", "debuglevel", "def", "echo", "else", "eval", "exit", "gosub", "goto", "if", "include", "match", "matchre", "matchwait", "math", "move", "nextroom", "pause", "put", "random", "replace", "replacere", "return", "save", "shift", "send", "setvariable", "then", "unvar", "var", "wait", "waiteval", "waitfor", "waitforre", "when", "#alias", "#beep", "#highlight", "#flash", "#goto", "#mapper", "#script", "#parse", "#var"])
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
            Characters(from:"\r\n").token("newline"),
            OKStandard.whiteSpaces,
            Characters(from:":").token("label"),
            Characters(from:";").token("split"),
            OutlanderStandard.indexer,
            Characters(from:"(").token("open-paren"),
            Characters(from:")").token("close-paren"),
            Characters(from:"{").token("open-bracket"),
            Characters(from:"}").token("close-bracket"),
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
    var trackingExpression = false
    var inBracketCount = 0
    
    var lineCommandStack = [String]()
    var lineCommands = ["action", "debug", "debuglevel", "echo", "eval", "exit", "gosub", "goto", "include", "match", "matchre", "matchwait", "math", "move", "nextroom", "pause", "put", "random", "return", "save", "shift", "send", "setvariable", "unvar", "var", "wait", "waiteval", "waitfor", "waitforre"]
    
    var validLabelTokens = ["globalvar", "variable", "localvar", "word", "keyword", "integer", "punct"]
   
    var funcCommandStack = [String]()
    var funcCommands = ["def", "countsplit", "matchre", "replace", "replacere"]
    
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
            endCommand(true)
        case _ where token.name == "keyword":
            // TODO: remove this once keyword bug is fixed (keyword matches partials)
            if(token.characters == "#") {
                createComment(token)
            }
            else if(token.characters == "if" && lineCommandStack.count == 0) {
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
            else if(token.characters == "else" && lineCommandStack.count == 0) {
                let elseToken = ElseIfToken(token.originalStringIndex!, token.originalStringLine!)
                pushToken(elseToken)
                ifStack.append(elseToken)
            }
            else if(token.characters == "then" && lineCommandStack.count == 0) {
                endIf()
                self.trackingExpression = false
            }
            else if lineCommandStack.count == 0 && contains(lineCommands, token.characters) {
                pushToken(CommandToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
                lineCommandStack.append(token.characters)
            }
            else if funcCommandStack.count == 0 && contains(funcCommands, token.characters){
                pushToken(FuncToken(token.characters, token.originalStringIndex!, token.originalStringLine!))
                funcCommandStack.append(token.characters)
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
            self.inBracketCount++
            pushToken(token)
        case _ where token.name == "close-bracket":
            if !ifStack.isEmpty {
                endIfBody()
            }
            else if lineCommandStack.count > 0 {
                pushToken(token)
            }
            self.inBracketCount--
        case _ where token.name == "label":
            if lineCommandStack.count == 0 {
                createLabel(token)
            } else {
                pushToken(token)
            }
        case _ where token.name == "comment":
            createComment(token)
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
    
    func createIndexer(token:Token) {
        var indexer = IndexerToken(token.characters, token.originalStringIndex!, token.originalStringLine!)
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
        var end = tokens.count
        
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
            current--
        }
    }
    
    func createEval(token:CommandToken) -> CommandToken {
        var evalToken = EvalCommandToken(token.originalStringIndex!, token.originalStringLine!)
        evalToken.body = token.body
        
        var foundVar = false
        var inExpression = false
        
        for (index, t) in enumerate(token.body) {
            if (t.name == "variable" || t.name == "globalvar") && !foundVar && !inExpression {
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
        var actionToken = ActionToken(token.originalStringIndex!, token.originalStringLine!)
        actionToken.body = token.body
        
        var action = [Token]()
        
        var pastWhen = false
        var inClass = false
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
        
        if !pastWhen && !contains(manageActions, actionText) {
            errors.append("No when pattern defined for action on line \(token.originalStringLine!+1)")
        }
        
        if contains(manageActions, actionText) {
            switch actionText {
            case "on":
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
    func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult
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
    
    public func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult {
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
    
    public func eval(simplify: (Array<Token>)->String) -> ExpressionEvalResult {
        var result = false
        let lhRes = left.eval(simplify)
        let rhRes = right.eval(simplify)
        
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
        
        var text = "\(lhRes.info) \(characters) \(rhRes.info) = \(result)"
        
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
    
    public func eval(tokens:Array<Token>) -> ExpressionEvalResult {
        func simplify(tokens:Array<Token>)->String {
            var text = ""
            
            for t in tokens {
                text += t.characters
            }
            
            return text
        }
        
        return self.eval(tokens, simplify)
    }
    
    public func eval(tokens:Array<Token>, _ simplify:(Array<Token>)->String) -> ExpressionEvalResult {
        
        for token in tokens {
            parse(token)
        }
        
        parse(EndToken())
        
        var result = false
        var info = ""
        
        if let evalToken = topToken() as? EvalToken {
           return evalToken.eval(simplify)
        }
        
        return ExpressionEvalResult(result:EvalResult.Boolean(val: false), info:info, matchGroups:nil)
    }
    
    override public func parse(token: Token) -> Bool {
        
        if let funcToken = token as? FuncToken {
            
            if funcToken.name == "matchre" {
                pushToken(MatchReEvalToken(funcToken))
            } else if funcToken.name == "countsplit" {
                pushToken(CountSplitEvalToken(funcToken))
            } else if funcToken.name == "def" {
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
        
        var left = popToken() as? EvalToken
        
        if let lh = left {
        
            var or = OrExpressionToken(left: lh, withOperator: op, right: right)
            
            pushToken(or)
        }
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

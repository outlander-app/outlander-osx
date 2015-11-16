//
//  TokenToMessage.swift
//  Outlander
//
//  Created by Joseph McBride on 11/7/15.
//  Copyright © 2015 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit

protocol TokenAction {
    func performAction(context:ScriptContext, token:Token) -> Message?
}

struct TokenActionWrapper<T: AnyObject> : TokenAction {
    weak var target: T?
    let action: T -> (context:ScriptContext, token:Token) -> Message?
    
    func performAction(context:ScriptContext, token:Token) -> Message? {
        if let t = target {
            return action(t)(context: context, token: token)
        }
        
        return nil
    }
}

public class TokenToMessageMap {
    var actions = [String: TokenAction]()
    
    func setTarget<T: AnyObject>(target: T, action: T -> (ScriptContext, token:Token) -> Message?, tokenName: String) {
        actions[tokenName] = TokenActionWrapper(target: target, action: action)
    }
    
    func hasAction(tokenName: String) -> Bool {
        return actions.keys.contains(tokenName)
    }
    
    func removeTargetForToken(tokenName: String) {
        actions[tokenName] = nil
    }
    
    func performActionForToken(context: ScriptContext, token: Token) -> Message? {
        return actions[token.name]?.performAction(context, token: token)
    }
}

public class TokenToMessage {
    
    var messageMap = TokenToMessageMap()
    
    init() {
        messageMap.setTarget(self, action: TokenToMessage.action, tokenName: "action")
        messageMap.setTarget(self, action: TokenToMessage.debug, tokenName: "debug")
        messageMap.setTarget(self, action: TokenToMessage.debug, tokenName: "debuglevel")
        messageMap.setTarget(self, action: TokenToMessage.echo, tokenName: "echo")
        messageMap.setTarget(self, action: TokenToMessage.eval, tokenName: "eval")
        messageMap.setTarget(self, action: TokenToMessage.exit, tokenName: "exit")
        messageMap.setTarget(self, action: TokenToMessage.goto, tokenName: "goto")
        messageMap.setTarget(self, action: TokenToMessage.matchre, tokenName: "matchre")
        messageMap.setTarget(self, action: TokenToMessage.matchwait, tokenName: "matchwait")
        messageMap.setTarget(self, action: TokenToMessage.math, tokenName: "math")
        messageMap.setTarget(self, action: TokenToMessage.pause, tokenName: "pause")
        messageMap.setTarget(self, action: TokenToMessage.put, tokenName: "put")
        messageMap.setTarget(self, action: TokenToMessage.random, tokenName: "random")
        messageMap.setTarget(self, action: TokenToMessage.save, tokenName: "save")
        messageMap.setTarget(self, action: TokenToMessage.send, tokenName: "send")
        messageMap.setTarget(self, action: TokenToMessage.unvar, tokenName: "unvar")
    }
    
    public func action(context:ScriptContext, token:Token) -> Message? {
        return ActionMessage(token as! ActionToken)
    }
    
    public func debug(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        let levelStr = cmd.bodyText()
        return DebugLevelMessage(Int(levelStr) ?? ScriptLogLevel.Actions.rawValue)
    }
    
    public func echo(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        return EchoMessage(
            context
                .simplifyEach(cmd.body)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        )
    }
    
    public func eval(context:ScriptContext, token:Token) -> Message? {
        return EvalMessage(token as! EvalCommandToken)
    }
    
    public func exit(context:ScriptContext, token:Token) -> Message? {
        return ExitMessage()
    }
    
    public func goto(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        var args = context.simplifyEach(cmd.body)
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            .componentsSeparatedByString(" ")
        
        let label = args.removeAtIndex(0)
        let allArgs = args.joinWithSeparator(" ")
        args.insert(allArgs, atIndex: 0)
        
        return GotoMessage(label, args)
    }
    
    public func matchwait(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        let timeoutStr = cmd.bodyText()
        return MatchwaitMessage(timeoutStr.toDouble())
    }
    
    public func matchre(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        var txt = cmd.bodyText().componentsSeparatedByString(" ")
        
        let label = txt.removeAtIndex(0)
        let value = txt.joinWithSeparator(" ")
        return MatchReMessage(label, value)
    }
    
    public func math(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        var variable = ""
        var operation = ""
        var number:Double = 0
        
        var evaled = context.simplify(cmd.bodyText()).componentsSeparatedByString(" ")
        
        if evaled.count > 2 {
            variable = evaled[0]
            operation = evaled[1]
            number = evaled[2].toDouble() ?? 0
        }
        
        return MathMessage(variable, operation, number)
    }
    
    public func pause(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        let lengthStr = cmd.bodyText()
        return PauseMessage(lengthStr.toDouble() ?? 1)
    }
    
    public func put(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        return PutMessage(
            context
                .simplifyEach(cmd.body)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        )
    }
    
    public func random(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        var nums = cmd.bodyText().componentsSeparatedByString(" ")
        
        var min = 0
        var max = 1
        
        if nums.count > 1 {
            min = Int(nums[0]) ?? 0
            max = Int(nums[1]) ?? 1
        }
        
        return RandomMessage(min, max)
    }
    
    public func save(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        let txt = context.simplify(cmd.bodyText())
        return SaveMessage(txt)
    }
    
    public func send(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        return SendMessage(
            context
                .simplifyEach(cmd.body)
                .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        )
    }
    
    public func unvar(context:ScriptContext, token:Token) -> Message? {
        let cmd = token as! CommandToken
        let txt = context.simplify(cmd.bodyText())
        return UnVarMessage(txt)
    }
    
    public func toMessage(context:ScriptContext, token:Token) -> Message? {
        
        var msg:Message? = UnknownMessage(token.description)
        
        if let branch = token as? BranchToken {
            
            msg = OperationComplete(branch.name, msg: branch.lastResult?.info ?? "")
            
        }
        else if let label = token as? LabelToken {
            
            msg = LabelMessage(label.characters)
            
        }
        else if let cmd = token as? CommandToken {
            if messageMap.hasAction(cmd.name) {
                return messageMap.performActionForToken(context, token: cmd)
            }
            
            let name = cmd.name
            switch name {
                
            case _ where name == "var", _ where name == "setvariable":
                
                if cmd.body.count < 2 {
                    break
                }
                
                var cmds = cmd.body
                var identifierCmd:Token?
                
                while cmds.count > 0 && (identifierCmd == nil || identifierCmd?.name == "whitespace") {
                    identifierCmd = cmds.removeAtIndex(0)
                }
                
                if identifierCmd == nil {
                    break
                }
                
                let identifier = context.simplify([identifierCmd!])
                let value = context.simplify(cmds)
                
                msg = VarMessage(identifier, value)
                
            case _ where cmd.name == "match":
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                let label = txt.removeAtIndex(0)
                let value = txt.joinWithSeparator(" ")
                
                msg = MatchMessage(label, value)
                
            case _ where cmd.name == "waitforre":
                msg = WaitforReMessage(cmd.bodyText())
                
            case _ where cmd.name == "waitfor":
                msg = WaitforMessage(cmd.bodyText())
                
            case _ where cmd.name == "wait":
                msg = WaitMessage()
                
            case _ where cmd.name == "waiteval":
                msg = WaitEvalMessage(cmd)
                
            case _ where name == "gosub":
                var args = context.simplifyEach(cmd.body)
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    .componentsSeparatedByString(" ")
                
                let label = args.removeAtIndex(0)
                let allArgs = args.joinWithSeparator(" ")
                args.insert(allArgs, atIndex: 0)
                
                msg = GosubMessage(label, args)
                
            case _ where name == "return":
                msg = ReturnMessage()
                
            case _ where name == "nextroom":
                msg = NextRoomMessage()
                
            case _ where name == "move":
                let direction = context.simplifyEach(cmd.body)
                msg = MoveMessage(direction.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                
            case _ where name == "shift":
                msg = ShiftMessage()
                
            default:
                msg = UnknownMessage(token.description)
            }
        } else if let _ = token as? CommentToken {
            msg = CommentMessage()
        }
        
        return msg
    }
}
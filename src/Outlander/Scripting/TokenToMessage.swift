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
        messageMap.setTarget(self, action: TokenToMessage.debug, tokenName: "debug")
        messageMap.setTarget(self, action: TokenToMessage.debug, tokenName: "debuglevel")
        messageMap.setTarget(self, action: TokenToMessage.echo, tokenName: "echo")
        messageMap.setTarget(self, action: TokenToMessage.eval, tokenName: "eval")
        messageMap.setTarget(self, action: TokenToMessage.pause, tokenName: "pause")
        messageMap.setTarget(self, action: TokenToMessage.put, tokenName: "put")
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
                
            case _ where name == "goto":
                var args = context.simplifyEach(cmd.body)
                    .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                    .componentsSeparatedByString(" ")
                
                let label = args.removeAtIndex(0)
                let allArgs = args.joinWithSeparator(" ")
                args.insert(allArgs, atIndex: 0)
                
                msg = GotoMessage(label, args)
                
                
            case _ where name == "send":
                msg = SendMessage(
                    context
                        .simplifyEach(cmd.body)
                        .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                )
                
            case _ where name == "math":
                
                var variable = ""
                var operation = ""
                var number:Double = 0
                
                var evaled = context.simplify(cmd.bodyText()).componentsSeparatedByString(" ")
                
                if evaled.count > 2 {
                    variable = evaled[0]
                    operation = evaled[1]
                    number = evaled[2].toDouble() ?? 0
                }
                
                msg = MathMessage(variable, operation, number)
                
            case _ where cmd.name == "unvar":
                let txt = context.simplify(cmd.bodyText())
                msg = UnVarMessage(txt)
                
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
                
            case _ where name == "save":
                let txt = context.simplify(cmd.bodyText())
                msg = SaveMessage(txt)
                
            case _ where cmd.name == "matchwait":
                let timeoutStr = cmd.bodyText()
                msg = MatchwaitMessage(timeoutStr.toDouble())
                
            case _ where cmd.name == "matchre":
                var txt = cmd.bodyText().componentsSeparatedByString(" ")
                
                let label = txt.removeAtIndex(0)
                let value = txt.joinWithSeparator(" ")
                msg = MatchReMessage(label, value)
                
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
                
            case _ where name == "random":
                var nums = cmd.bodyText().componentsSeparatedByString(" ")
                
                var min = 0
                var max = 1
                
                if nums.count > 1 {
                    min = Int(nums[0]) ?? 0
                    max = Int(nums[1]) ?? 1
                }
                
                msg = RandomMessage(min, max)
                
            case _ where name == "return":
                msg = ReturnMessage()
                
            case _ where name == "nextroom":
                msg = NextRoomMessage()
                
            case _ where name == "move":
                let direction = context.simplifyEach(cmd.body)
                msg = MoveMessage(direction.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                
            case _ where name == "shift":
                msg = ShiftMessage()
                
            case _ where name == "exit":
                msg = ExitMessage()
                
            case _ where name == "action":
                msg = ActionMessage(cmd as! ActionToken)
                
            default:
                msg = UnknownMessage(token.description)
            }
        } else if let _ = token as? CommentToken {
            msg = CommentMessage()
        }
        
        return msg
    }
}
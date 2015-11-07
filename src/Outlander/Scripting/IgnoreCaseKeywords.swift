//
//  IgnoreCaseKeywords.swift
//  Outlander
//
//  Created by Joseph McBride on 5/10/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation
import OysterKit

public class IgnoreCaseKeywords : TokenizationState {
    public override func stateClassName()->String {
        return "IgnoreCaseKeywords"
    }
    
    let validStrings : [String]
    let  eot : Character = "\u{04}"
    let whiteSpaceString = " \t\r\n"
    
    public init(validStrings:Array<String>){
        self.validStrings = validStrings
        super.init()
    }
    
    public override func scan(operation: TokenizeOperation) {
        operation.debug("Entered Keywords \(validStrings)")
        
        var didAdvance = false
        
        if completions("\(operation.context.consumedCharacters)\(operation.current)".lowercaseString) == nil {
            return
        }
        
        while let allCompletions = completions("\(operation.context.consumedCharacters)\(operation.current)".lowercaseString) {
            if allCompletions.count == 1 {
            
                let keyword = allCompletions[0]
                let test = "\(operation.context.consumedCharacters)\(operation.current)".lowercaseString
            
                if keyword == test && isWhiteSpaceOrEot(operation.next) {
                    
                    operation.advance()
                
                    //Pursue our branches
                    emitToken(operation, useCharacters: test)
                    
                    if operation.context.consumedCharacters.characters.count > 0 {
                        scanBranches(operation)
                    }
                    return
                }
                else {
                    operation.advance()
                    didAdvance = true
                }
            } else {
                operation.advance()
                didAdvance = true
            }
        }
        
        if (didAdvance){
            scanBranches(operation)
            return
        }
    }
    
    func isWhiteSpaceOrEot(next:Character?) -> Bool {
        
        for c in self.whiteSpaceString.characters {
            if next == c {
                return true
            }
        }
        
        return next == eot
    }
    
    func completions(string:String) -> Array<String>?{
        var allMatches = Array<String>()
        
        for validString in validStrings{
            if validString.lowercaseString.hasPrefix(string){
                allMatches.append(validString.lowercaseString)
            }
        }
        
        if allMatches.count == 0{
            return nil
        } else {
            return allMatches
        }
    }
}
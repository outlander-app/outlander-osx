//
//  ExpUpdateHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 4/23/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

@objc
class ExpUpdateHandler : NSObject {
    
    class func newInstance() -> ExpUpdateHandler {
        return ExpUpdateHandler()
    }
   
    static let start_check = "Circle: "
    static let end_check = "EXP HELP for more information"
    
    var emitSetting : ((String,String)->Void)?
    var emitExp : ((SkillExp)->Void)?
    
    private var parsing = false
    private var exp_regex = "(\\w.*?):\\s+(\\d+)\\s(\\d+)%\\s(\\w.*?)\\s+\\(\\d{1,}/34\\)"
    
    func handle(nodes:[Node], text:String, context:GameContext) {
        
        if !self.parsing {
            if text.hasPrefix(ExpUpdateHandler.start_check) {
                self.parsing = true
                return
            }
        } else {
        
            if text.hasPrefix(ExpUpdateHandler.end_check) {
                self.parsing = false
                return
            }
            
            let groups = text[exp_regex].allGroups()
            
            for group in groups {
                
                let var_name = group[1].replace(" ", withString: "_")
                
                let skill = SkillExp()
                skill.name = var_name
                skill.mindState = LearningRate.fromDescription(group[4])
                skill.ranks = NSDecimalNumber(string: "\(group[2]).\(group[3])")
                
                
                emitSetting?("\(var_name).Ranks", "\(skill.ranks)")
                emitSetting?("\(var_name).LearningRate", "\(skill.mindState.rateId)")
                emitSetting?("\(var_name).LearningRateName", "\(skill.mindState.desc)")
                
                emitExp?(skill)
            }
        }
    }
}

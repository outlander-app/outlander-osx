//
//  ExpressionEvaluator.swift
//  Outlander
//
//  Created by Joseph McBride on 4/7/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

class ExpressionEvaluator {

    func evaluateLogic(_ input:String) -> Bool {
        guard input.characters.count > 0 else {
            return false
        }

        do {
            var result = false
            try ObjC.catchException {
                let predicate = NSPredicate(format: input)
                result = predicate.evaluate(with: nil)
            }
            return result
        } catch {
            return false
        }
    }

    func evaluateValue<T>(_ input:String) -> T? {
        guard input.characters.count > 0 else {
            return nil
        }

        do {
            var result:T?
            try ObjC.catchException {
                let expression = NSExpression(format: input)
                result = expression.expressionValue(with: nil, context: nil) as? T
            }
            return result
        } catch {
            return nil
        }
    }
}

//
//  ArrayExtensions.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

extension Array {
    func forEach(_ doThis: (_ element: Element) -> Void) {
        for e in self {
            doThis(e)
        }
    }

    func find(_ includedElement: (Element) -> Bool) -> Int? {
        for (idx, element) in self.enumerated() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}

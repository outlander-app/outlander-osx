//
//  ArrayExtensions.swift
//  Outlander
//
//  Created by Joseph McBride on 3/24/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

extension Array {
    func forEach(doThis: (element: Element) -> Void) {
        for e in self {
            doThis(element: e)
        }
    }

    func find(includedElement: Element -> Bool) -> Int? {
        for (idx, element) in self.enumerate() {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}

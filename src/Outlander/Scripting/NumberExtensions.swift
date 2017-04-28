//
//  NumberExtensions.swift
//  Outlander
//
//  Created by Joseph McBride on 4/27/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

extension Double {
    var isInteger: Bool {
        return rint(self) == self
    }
}

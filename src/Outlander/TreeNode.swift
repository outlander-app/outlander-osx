//
//  TreeNode.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/1/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

@objc(OLTreeNode)
public class TreeNode : NSObject {
    var id:String
    var parent:TreeNode?
    
    init(id:String, parent:TreeNode?) {
        self.id = id
        self.parent = parent
    }
    
    // Heuristic Value
    @objc
    public var hValue: Int = 0
    
    // Move Cost
    @objc
    public var gValue: Int = 0
    
    // The total cost (h + g)
    @objc
    public var fValue: Int {
        return hValue + gValue
    }
    
    @objc
    public override var hashValue : Int {
        return self.id.hashValue
    }
}

public func ==(lhs: TreeNode, rhs: TreeNode) -> Bool {
  return lhs === rhs
}

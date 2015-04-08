//
//  Pathfinder.swift
//  TestMapper
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation

public class Pathfinder {
    
    func findPath(start:String, target:String, zone:MapZone) -> [String]{
        
        var openList:[TreeNode] = []
        var closedList:[TreeNode] = []
        
        var startNode = zone.roomWithId(start)!
        var targetNode = zone.roomWithId(target)!
        
        openList.append(TreeNode(id: startNode.id, parent: nil))
        
        var found:TreeNode?
        
        while let current = nodeWithLowestFScore(openList) {
            
            println("checking: \(current.id)")
            
            closedList.append(current)
            openList.removeAtIndex(find(openList, current)!)
            
            if self.isInList(closedList, node: targetNode) {
                // found path
                found = current
                break
            }
            
            var currentMapNode = zone.roomWithId(current.id)!
            
            let sorted = currentMapNode.arcs
                .filter { countElements($0.destination) > 0 }
                .sorted { $0.destination.toInt()! < $1.destination.toInt()! }
            
            for arc in sorted {
                
                let room = zone.roomWithId(arc.destination)!
                var treeNode = nodeInList(openList, mapNode: room)
                
                let moveCost = zone.moveCostForNode(currentMapNode, toNode: room)
                
                if self.isInList(closedList, node: room) { //&& (current.gValue + moveCost) >=  treeNode?.gValue {
                    continue
                }
                
                if treeNode != nil {
                    
                    treeNode!.parent = current
                    treeNode!.gValue = current.gValue + moveCost
                    
                } else {
                    
                    var newNode = TreeNode(id: room.id, parent: current)
                    
                    newNode.gValue = current.gValue + moveCost
                    newNode.hValue = zone.hValueForNode(room, endNode: targetNode)
                    
                    openList.append(newNode)
                }
            }
        }
        
        // back track from the end node
        if let path = found {
            return backTrack(path)
        }
        
        // there is no route
        return []
    }
    
    func backTrack(path:TreeNode) -> [String] {
        var shortestPath:[String] = []
        
        var step:TreeNode? = path
        
        do {
            if step?.parent != nil {
                shortestPath.insert(step!.id, atIndex: 0)
            }
            step = step?.parent
        } while step?.parent != nil
       
        if step != nil {
            shortestPath.insert(step!.id, atIndex: 0)
        }
        
        return shortestPath
    }
    
    func getMoves(ids:[String], zone:MapZone) -> [String] {
        var moves:[String] = []
        
        var last:MapNode?
        
        for id in ids {
            
            if let to = last {
                if let arc = to.arcWithId(id) {
                    moves.append(arc.move)
                }
            }
            
            last = zone.roomWithId(id)
        }
        
        return moves
    }
    
    func nodeWithLowestFScore(list:[TreeNode]) -> TreeNode? {
        return list.sorted { $0.fValue < $1.fValue }.first
    }
    
    func nodeInList(list:[TreeNode], mapNode:MapNode) -> TreeNode? {
        return list.filter { $0.id == mapNode.id }.first
    }
    
    func isInList(list:[TreeNode], node:MapNode) -> Bool {
        return list.filter { $0.id == node.id }.count > 0
    }
}
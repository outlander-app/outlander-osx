//
//  MapLoader.swift
//  TestMapper
//
//  Created by Joseph McBride on 3/31/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation
import GlimpseXML

enum MapLoadResult {
    case Success(MapZone)
    case Error(XMLError)
}

enum MapMetaResult {
    case Success(MapInfo)
    case Error(XMLError)
}

final class MapInfo {
    var id:String
    var name:String
    var file:String
    var zone:MapZone?
    
    init(_ id: String, name: String, file: String){
        self.id = id
        self.name = name
        self.file = file
    }
}

extension MapInfo: Equatable {}

// MARK: Equatable

func ==(lhs: MapInfo, rhs: MapInfo) -> Bool {
    return lhs.id == rhs.id
}

final class MapLoader {
    
    func loadFolder(folder: String) -> [MapMetaResult] {
        
        let fileManager = NSFileManager.defaultManager()
        let enumerator:NSDirectoryEnumerator? = fileManager.enumeratorAtPath(folder)
        
        var files:[String] = []
        
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".xml") {
                files.append(element)
            }
        }
        
        return files.map { self.loadMeta($0, folder: folder) }
    }
    
    func loadMeta(file: String, folder: String) -> MapMetaResult {
        
        println("Loading \(file)")
        
        var filePath = folder.stringByAppendingPathComponent(file)
        
        let parsed = GlimpseXML.Document.parseFile(filePath)
        
        switch parsed {
        case .Error(let err):
            return MapMetaResult.Error(err)
            
        case .Value(let val):
            let doc: GlimpseXML.Document = val.value
            
            var id = doc.rootElement.attributeValue("id", namespace: nil)!
            var name = doc.rootElement.attributeValue("name", namespace: nil)!
            
            return MapMetaResult.Success(
                MapInfo(id, name: name, file: file)
            )
        }
    }
    
    func load(filePath: String) -> MapLoadResult {
        
        let parsed = GlimpseXML.Document.parseFile(filePath)
        
        switch parsed {
        case .Error(let err):
            return MapLoadResult.Error(err)
            
        case .Value(let val):
            let doc: GlimpseXML.Document = val.value
            
            var id = doc.rootElement.attributeValue("id")!
            var name = doc.rootElement.attributeValue("name")!
            
            var mapZone = MapZone(id, name)
            
            if let roomNodes = doc.xpath("/zone/node").value {
                
                for n in roomNodes {
                    var desc = self.descriptions(n.children)
                    var position = self.position(n.children)
                    var arcs = self.arcs(n.children)
                    var room =  MapNode(
                        id: n.attributeValue("id")!,
                        name: n.attributeValue("name")!,
                        descriptions: desc,
                        notes: n.attributeValue("note"),
                        color: n.attributeValue("color"),
                        position: position,
                        arcs: arcs)
                    
                    mapZone.addRoom(room)
                }
            }
            
            if let labelNodes = doc.xpath("/zone/label").value {
                mapZone.labels = labelNodes.map {
                    var text = $0.attributeValue("text") ?? ""
                    var position = self.position($0.children)
                    
                    return MapLabel(text: text, position: position)
                }
            }
            
            return MapLoadResult.Success(mapZone)
        }
    }
    
    private func descriptions(nodes:[GlimpseXML.Node]) -> [String] {

        return nodes
            .filter { $0.name == "description" }
            .map { $0.text ?? "" }
    }
    
    private func arcs(nodes:[GlimpseXML.Node]) -> [MapArc] {

        return nodes
            .filter {$0.name == "arc"}
            .map {
                MapArc(
                    exit: $0.attributeValue("exit") ?? "",
                    move: $0.attributeValue("move") ?? "",
                    destination: $0.attributeValue("destination") ?? "",
                    hidden: $0.attributeValue("hidden") == "True")
        }
    }
    
    func position(items:[GlimpseXML.Node]) -> MapPosition {
        
        let filtered = items.filter { $0.name == "position" }
        
        if filtered.count > 0 {
            let item = filtered[0]
            return MapPosition(
                x: item.attributeValue("x")!.toInt()!,
                y: item.attributeValue("y")!.toInt()!,
                z: item.attributeValue("z")!.toInt()!
            )
        }
        
        return MapPosition(x: 0, y: 0, z: 0)
    }
}
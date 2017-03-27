//
//  MapLoader.swift
//  TestMapper
//
//  Created by Joseph McBride on 3/31/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation
//import GlimpseXML

enum MapLoadResult {
    case success(MapZone)
    case error(Error)
}

enum MapMetaResult {
    case success(MapInfo)
    case error(Error)
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
    
    func loadFolder(_ folder: String) -> [MapMetaResult] {
        
        let fileManager = FileManager.default
        let enumerator:FileManager.DirectoryEnumerator? = fileManager.enumerator(atPath: folder)
        
        var files:[String] = []
        
        while let element = enumerator?.nextObject() as? String {
            if element.hasSuffix(".xml") {
                files.append(element)
            }
        }
        
        return files.map { self.loadMeta($0, folder: folder) }
    }
    
    func loadMeta(_ file: String, folder: String) -> MapMetaResult {
        
        print("Loading \(file)")
        
        let filePath = folder.stringByAppendingPathComponent(file)

        do {
//            let doc = try GlimpseXML.Document.parseFile(filePath)
//
//            let id = doc.rootElement.attributeValue("id", namespace: nil)!
//            let name = doc.rootElement.attributeValue("name", namespace: nil)!
//            
            return MapMetaResult.success(
                MapInfo("", name: "", file: "")
            )
        } catch let error {
            return MapMetaResult.error(error)
        }
    }
    
    func load(_ filePath: String) -> MapLoadResult {

        do {
//            let doc = try GlimpseXML.Document.parseFile(filePath)
//
//            let id = doc.rootElement.attributeValue("id")!
//            let name = doc.rootElement.attributeValue("name")!
//            
            let mapZone = MapZone("", "")
//
//            let roomNodes = try doc.xpath("/zone/node")
//
//            for n in roomNodes {
//                let desc = self.descriptions(n.children)
//                let position = self.position(n.children)
//                let arcs = self.arcs(n.children)
//                let room =  MapNode(
//                    id: n.attributeValue("id")!,
//                    name: n.attributeValue("name")!,
//                    descriptions: desc,
//                    notes: n.attributeValue("note"),
//                    color: n.attributeValue("color"),
//                    position: position,
//                    arcs: arcs)
//
//                mapZone.addRoom(room)
//            }
//
//            let labelNodes = try doc.xpath("/zone/label")
//            mapZone.labels = labelNodes.map {
//                let text = $0.attributeValue("text") ?? ""
//                let position = self.position($0.children)
//
//                return MapLabel(text: text, position: position)
//            }

            return MapLoadResult.success(mapZone)
        }
        catch let error {
            return MapLoadResult.error(error)
        }
    }
    
//    fileprivate func descriptions(_ nodes:[GlimpseXML.Node]) -> [String] {
//
//        return nodes
//            .filter { $0.name == "description" }
//            .map { $0.text ?? "" }
//    }
//    
//    fileprivate func arcs(_ nodes:[GlimpseXML.Node]) -> [MapArc] {
//
//        return nodes
//            .filter {$0.name == "arc"}
//            .map {
//                MapArc(
//                    exit: $0.attributeValue("exit") ?? "",
//                    move: $0.attributeValue("move") ?? "",
//                    destination: $0.attributeValue("destination") ?? "",
//                    hidden: $0.attributeValue("hidden") == "True")
//        }
//    }
//    
//    func position(_ items:[GlimpseXML.Node]) -> MapPosition {
//        
//        let filtered = items.filter { $0.name == "position" }
//        
//        if filtered.count > 0 {
//            let item = filtered[0]
//            return MapPosition(
//                x: Int(item.attributeValue("x")!)!,
//                y: Int(item.attributeValue("y")!)!,
//                z: Int(item.attributeValue("z")!)!
//            )
//        }
//        
//        return MapPosition(x: 0, y: 0, z: 0)
//    }
}

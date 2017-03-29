//
//  MapLoader.swift
//  TestMapper
//
//  Created by Joseph McBride on 3/31/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation
//import GlimpseXML
import AEXML

enum MapErrors : Error {
    case noFile
}

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

        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return MapMetaResult.error(MapErrors.noFile)
        }

        do {
            let doc = try AEXMLDocument(xml: data)

            let id = doc.root.attributes["id"]
            let name = doc.root.attributes["name"]

            return MapMetaResult.success(
                MapInfo(id!, name: name!, file: file)
            )
        } catch let error {
            return MapMetaResult.error(error)
        }
    }
    
    func load(_ filePath: String) -> MapLoadResult {

        do {

            guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
                return MapLoadResult.error(MapErrors.noFile)
            }

            let doc = try AEXMLDocument(xml: data)

            let id = doc.root.attributes["id"]
            let name = doc.root.attributes["name"]

            let mapZone = MapZone(id!, name!)

            if let roomNodes = doc.root["node"].all {
                for n in roomNodes {

                    let room = MapNode(
                        id: n.attributes["id"]!,
                        name: n.attributes["name"]!,
                        descriptions: self.description(n.children),
                        notes: n.attributes["note"],
                        color: n.attributes["color"],
                        position: self.position(n.children),
                        arcs: self.arcs(n.children)
                    )

                    mapZone.addRoom(room)
                }
            }

            if let labels = doc.root["label"].all {
                mapZone.labels = labels.map {
                    let text = $0.attributes["text"] ?? ""
                    let position = self.position($0.children)

                    return MapLabel(text: text, position: position)
                }
            }

            return MapLoadResult.success(mapZone)
        }
        catch let error {
            return MapLoadResult.error(error)
        }
    }

    fileprivate func description(_ nodes:[AEXMLElement]) -> [String] {
        return nodes
            .filter { $0.name == "description" }
            .map { $0.value ?? "" }
    }

    fileprivate func arcs(_ nodes:[AEXMLElement]) -> [MapArc] {
        return nodes
            .filter { $0.name == "arc" }
            .map {
                MapArc(
                    exit: $0.attributes["exit"] ?? "",
                    move: $0.attributes["move"] ?? "",
                    destination: $0.attributes["destination"] ?? "",
                    hidden: $0.attributes["hidden"] == "True")
            }
    }

    fileprivate func position(_ nodes:[AEXMLElement]) -> MapPosition {
        let filtered = nodes.filter { $0.name == "position" }
        
        if filtered.count > 0 {
            let item = filtered[0]
            return MapPosition(
                x: Int(item.attributes["x"]!)!,
                y: Int(item.attributes["y"]!)!,
                z: Int(item.attributes["z"]!)!
            )
        }
        
        return MapPosition(x: 0, y: 0, z: 0)
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

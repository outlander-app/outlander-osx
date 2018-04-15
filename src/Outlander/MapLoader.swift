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
    case Error(ErrorType)
}

enum MapMetaResult {
    case Success(MapInfo)
    case Error(ErrorType)
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

        let directoryURL = NSURL(fileURLWithPath: folder, isDirectory: true)
        let fileManager = NSFileManager.defaultManager()

        let options: NSDirectoryEnumerationOptions = [.SkipsHiddenFiles, .SkipsSubdirectoryDescendants]

        let enumerator = fileManager.enumeratorAtURL(
            directoryURL,
            includingPropertiesForKeys: [NSURLNameKey],
            options: options,
            errorHandler: { (url, error) -> Bool in
                print("directoryEnumerator error at \(url): ", error)
                return true
        })

        var files:[String] = []

        while let element = enumerator?.nextObject() as? NSURL {
            if (element.lastPathComponent?.hasSuffix(".xml")) == true {
                files.append(element.lastPathComponent!)
            }
        }
        
        return files.map { self.loadMeta($0, folder: folder) }
    }
    
    func loadMeta(file: String, folder: String) -> MapMetaResult {
        
        print("Loading \(file)")
        
        let filePath = folder.stringByAppendingPathComponent(file)

        do {
            let doc = try GlimpseXML.Document.parseFile(filePath)

            let id = doc.rootElement.attributeValue("id", namespace: nil)!
            let name = doc.rootElement.attributeValue("name", namespace: nil)!
            
            return MapMetaResult.Success(
                MapInfo(id, name: name, file: file)
            )
        } catch let error {
            return MapMetaResult.Error(error)
        }
    }
    
    func load(filePath: String) -> MapLoadResult {

        do {
            let doc = try GlimpseXML.Document.parseFile(filePath)

            let id = doc.rootElement.attributeValue("id")!
            let name = doc.rootElement.attributeValue("name")!
            
            let mapZone = MapZone(id, name)

            let roomNodes = try doc.xpath("/zone/node")

            for n in roomNodes {
                let desc = self.descriptions(n.children)
                let position = self.position(n.children)
                let arcs = self.arcs(n.children)
                let room =  MapNode(
                    id: n.attributeValue("id")!,
                    name: n.attributeValue("name")!,
                    descriptions: desc,
                    notes: n.attributeValue("note"),
                    color: n.attributeValue("color"),
                    position: position,
                    arcs: arcs)

                mapZone.addRoom(room)
            }

            let labelNodes = try doc.xpath("/zone/label")
            mapZone.labels = labelNodes.map {
                let text = $0.attributeValue("text") ?? ""
                let position = self.position($0.children)

                return MapLabel(text: text, position: position)
            }

            return MapLoadResult.Success(mapZone)
        }
        catch let error {
            return MapLoadResult.Error(error)
        }
    }
    
    private func descriptions(nodes:[GlimpseXML.Node]) -> [String] {

        return nodes
            .filter { $0.name == "description" }
            .map { $0.text?.replace("\"", withString: "").replace(";", withString: "") ?? "" }
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
                x: Int(item.attributeValue("x")!)!,
                y: Int(item.attributeValue("y")!)!,
                z: Int(item.attributeValue("z")!)!
            )
        }
        
        return MapPosition(x: 0, y: 0, z: 0)
    }
}

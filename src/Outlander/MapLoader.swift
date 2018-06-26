//
//  MapLoader.swift
//  TestMapper
//
//  Created by Joseph McBride on 3/31/15.
//  Copyright (c) 2015 Outlander. All rights reserved.
//

import Foundation
import Fuzi

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
            let doc3 = try XMLDocument(data: NSData(contentsOfFile: filePath)!)

            let id = doc3.root?.attr("id") ?? ""
            let name = doc3.root?.attr("name") ?? ""

            return MapMetaResult.Success(
                MapInfo(id, name: name, file: file)
            )
        } catch let error {
            return MapMetaResult.Error(error)
        }
    }

    func measure<A>(name: String = "", _ block: () throws -> A) throws -> A {
        let startTime = CACurrentMediaTime()
        let result = try block()
        let timeElapsed = CACurrentMediaTime() - startTime
        print("Time: \(name) - \(timeElapsed)")
        return result
    }
    
    func load(filePath: String) -> MapLoadResult {

        do {
            let doc = try XMLDocument(data: NSData(contentsOfFile: filePath)!)

            let id = doc.root!.attr("id")!
            let name = doc.root!.attr("name")!

            let mapZone = MapZone(id, name)
            
            for node in doc.xpath("/zone/node") {
                let desc:[String] = self.descriptions(node)
                let position:MapPosition = self.position(node)
                let arcs:[MapArc] = self.arcs(node)
                let room = MapNode(
                    id: node["id"]!,
                    name: node["name"]!,
                    descriptions: desc,
                    notes: node["note"],
                    color: node["color"],
                    position: position,
                    arcs: arcs
                )
                mapZone.addRoom(room)
            }

            mapZone.labels = doc.xpath("/zone/label").map {
                let text = $0["text"] ?? ""
                let position:MapPosition = self.position($0)
                return MapLabel(text: text, position: position)
            }

            return MapLoadResult.Success(mapZone)
        }
        catch let error {
            return MapLoadResult.Error(error)
        }
    }

    private func descriptions(node:Fuzi.XMLElement) -> [String] {
        return node.xpath("description").map {
            return $0.stringValue.replace("\"", withString: "").replace(";", withString: "") ?? ""
        }
    }

    private func position(node:Fuzi.XMLElement) -> MapPosition {
        if let element = node.firstChild(tag: "position") {
            return MapPosition(x: Int(element["x"]!)!, y: Int(element["y"]!)!, z: Int(element["z"]!)!)
        }
        return MapPosition(x: 0, y: 0, z: 0)
    }

    private func arcs(node:Fuzi.XMLElement) -> [MapArc] {
        return node.xpath("arc").map {
            return MapArc(
                exit: $0["exit"] ?? "",
                move: $0["move"] ?? "",
                destination: $0["destination"] ?? "",
                hidden: $0["hidden"] == "True")
        }
    }
}

//
//  AutoMapperWindowController.swift
//  Outlander
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

func loadMap <R> (
    backgroundClosure: () -> R,
    mainClosure: (result: R) -> ())
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        let result = backgroundClosure()
        dispatch_async(dispatch_get_main_queue(), {
            mainClosure(result: result)
        })
    }
}

func mainThread(mainClosure: () -> ()) {
    dispatch_async(dispatch_get_main_queue(), {
        mainClosure()
    })
}

class MapsDataSource : NSObject, NSComboBoxDataSource {
    
    private var maps:[MapInfo] = []
    
    func loadMaps(mapsFolder:String, mapLoader:MapLoader, loaded: (()->Void)?) {
        
        { () -> [MapMetaResult] in
            
            return mapLoader.loadFolder(mapsFolder)
            
        } ~> { (results) ->() in
            
            var success:[MapInfo] = []
            
            for res in results {
                switch res {
                    
                case let .Success(mapInfo):
                    success.append(mapInfo)
                    
                case let .Error(error):
                    println("\(error)")
                }
            }
            
            self.maps = success.sorted { $0.id.compare($1.id, options: NSStringCompareOptions.NumericSearch, range: $0.id.startIndex..<$0.id.endIndex, locale:nil) == NSComparisonResult.OrderedAscending }
            
            loaded?()
        }
    }
    
    func mapForId(id:String) -> MapInfo? {
        return self.maps.filter { $0.id == id }.first
    }
    
    func mapForFile(file:String) -> MapInfo? {
        return self.maps.filter { $0.file == file }.first
    }
    
    func mapAtIndex(index:Int) -> MapInfo {
        return self.maps[index];
    }
    
    func indexOfMap(id:String) -> Int? {
        
        if let info = mapForId(id) {
            return find(self.maps, info)
        }
        
        return nil
    }
    
    // MARK - NSComboBoxDataSource
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return self.maps.count
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        let map = self.maps[index]
        return "\(map.id). \(map.name)"
    }
    
}

class AutoMapperWindowController: NSWindowController, NSComboBoxDataSource {
    
    @IBOutlet weak var mapsComboBox: NSComboBox!
    @IBOutlet weak var nodesLabel: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var mapLevelLabel: NSTextField!
    @IBOutlet weak var nodeNameLabel: NSTextField!
    
    private var mapsDataSource: MapsDataSource = MapsDataSource()
    
    private var context:GameContext?
    private let mapLoader:MapLoader = MapLoader()
    
    var mapLevel:Int = 0 {
        didSet {
            self.mapView.mapLevel = self.mapLevel
            self.mapLevelLabel.stringValue = "Level: \(self.mapLevel)"
        }
    }
    
    var mapZoom:CGFloat = 1.0 {
        didSet {
            if self.mapZoom == 0 {
                self.mapZoom = 0.5
            }
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        self.nodeNameLabel.stringValue = ""
        
        self.mapsComboBox.dataSource = self.mapsDataSource
        self.mapView.nodeHover = { node in
            if let room = node {
                var notes = ""
                if room.notes != nil {
                    notes = "(\(room.notes!))"
                }
                self.nodeNameLabel.stringValue = "#\(room.id) - \(room.name) \(notes)"
            } else {
                self.nodeNameLabel.stringValue = ""
            }
        }
    }
    
    func setSelectedZone() {
        if let zone = self.context?.mapZone {
            
            if let idx = self.mapsDataSource.indexOfMap(zone.id) {
                
                self.mapsComboBox.selectItemAtIndex(idx)
                
                self.renderMap(zone)
                
            }
            
        }
    }
    
    func setContext(context:GameContext) {
        self.context = context
        
        self.context?.globalVars.changed.subscribeNext { (obj:AnyObject?) -> Void in
            
            if self.mapView == nil {
                return
            }
            
            if let changed = obj as? Dictionary<String, String> {
                if changed.keys.first == "roomid" {
                    
                    var roomId = changed["roomid"]
                    
                    if let id = roomId {
                        if let room = self.context!.mapZone?.roomWithId(id) {
                            
                            if room.notes != nil && room.notes!.rangeOfString(".xml") != nil {
                                
                                let groups = room.notes!["(.+\\.xml)"].groups()
                                
                                if groups.count > 1 {
                                    let mapfile = groups[1]
                                    
                                    if let mapInfo = self.mapsDataSource.mapForFile(mapfile) {
                                        
                                        if let idx = self.mapsDataSource.indexOfMap(mapInfo.id) {
                                            
                                            mainThread {
                                            
                                                if self.mapsComboBox != nil {
                                                    self.mapsComboBox.selectItemAtIndex(idx)
                                                }
                                                else {
                                                    
                                                    if mapInfo.zone != nil {
                                                        
                                                        self.renderMap(mapInfo.zone!)
                                                        self.context?.mapZone = mapInfo.zone!
                                                        
                                                    } else {
                                                        self.loadMapFromInfo(mapInfo)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                mainThread {
                                    self.mapView.currentRoomId = roomId
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func findCurrentRoom(zone:MapZone) -> MapNode? {
        if let ctx = self.context {
            
            var roomId = ctx.globalVars.cacheObjectForKey("roomid") as? String
            
            var name = ctx.globalVars.cacheObjectForKey("roomtitle") as? String ?? ""
            name = name.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "[]"))
            
            let description = ctx.globalVars.cacheObjectForKey("roomdesc") as? String ?? ""
            
            if let room = zone.findRoomFuzyFrom(roomId, name: name, description: description) {
                
                ctx.globalVars.setCacheObject(room.id, forKey: "roomid")
                
                return room
            }
        }
        
        return nil
    }
    
    func loadMaps() {
        if let mapsFolder = self.context?.pathProvider.mapsFolder() {
            
            if self.nodesLabel != nil {
                self.nodesLabel.stringValue = "Loading Maps ..."
            }
            
            self.mapsDataSource.loadMaps(mapsFolder, mapLoader: self.mapLoader, loaded: { ()->Void in
                if self.nodesLabel != nil {
                    self.nodesLabel.stringValue = ""
                }
                
                if let zoneId = self.context!.globalVars.cacheObjectForKey("zoneid") as? String {
                    
                    if let idx = self.mapsDataSource.indexOfMap(zoneId) {
                        if self.mapsComboBox != nil {
                            self.mapsComboBox.selectItemAtIndex(idx)
                        } else {
                            self.loadMapFromInfo(self.mapsDataSource.mapAtIndex(idx))
                        }
                    }
                }
            })
        }
    }
    
    func renderMap(zone:MapZone) {
        
        var room = self.findCurrentRoom(zone)
        
        var rect = zone.mapSize(0, padding: 100.0)
        
        self.mapLevel = 0
        
        self.mapView?.setFrameSize(rect.size)
        self.mapView?.currentRoomId = room != nil ? room!.id : ""
        self.mapView?.setZone(zone, rect: rect)
        
        let roomCount = zone.rooms.count
        
        self.nodesLabel.stringValue = "Map Rooms: \(roomCount)"
    }
    
    func loadMapFromInfo(info:MapInfo) {
        
        if let mapsFolder = context?.pathProvider.mapsFolder() {
            
            let file = mapsFolder.stringByAppendingPathComponent(info.file)
           
            if self.nodesLabel != nil {
                self.nodesLabel.stringValue = "Loading ..."
            }
            
            let start = NSDate()
            
            loadMap({ () -> MapLoadResult in
                return self.mapLoader.load(file)
            }, { (result) -> () in
                
                let diff = NSDate().timeIntervalSinceDate(start)
                
                switch result {
                    
                case let .Success(zone):
                    
                    println("map \(zone.name) loaded in: \(diff) seconds")
                    
                    self.context?.mapZone = zone
                    
                    info.zone = zone
                    
                    if self.mapView != nil {
                        
                        self.renderMap(zone)
                    }
                    
                case let .Error(error):
                    println("map loaded with error in: \(diff) seconds")
                    if self.nodesLabel != nil {
                        self.nodesLabel.stringValue = "Error loading map: \(error)"
                    }
                }
            })
        }
        
    }
    
    @IBAction func mapLevelAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.mapLevel++
        } else {
            self.mapLevel--
        }
    }
    
    @IBAction func mapZoomAction(sender: NSSegmentedControl) {
        if sender.selectedSegment == 0 {
            self.mapZoom += 0.5
        } else {
            self.mapZoom -= 0.5
        }
        
        var clipView = self.scrollView.contentView
        var clipViewBounds = clipView.bounds
        var clipViewSize = clipView.frame.size
        
        clipViewBounds.size.width = clipViewSize.width / self.mapZoom
        clipViewBounds.size.height = clipViewSize.height / self.mapZoom
        
        clipView.setBoundsSize(clipViewBounds.size)
    }
    
    func comboBoxSelectionDidChange(notification: NSNotification) {
        let idx = self.mapsComboBox.indexOfSelectedItem
        let selectedMap = self.mapsDataSource.mapAtIndex(idx)
        
        if selectedMap.zone != nil {
            
            self.renderMap(selectedMap.zone!)
            
            self.context?.mapZone = selectedMap.zone!
            
            return
        }
        
        self.loadMapFromInfo(selectedMap)
    }

}

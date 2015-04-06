//
//  AutoMapperWindowController.swift
//  Outlander
//
//  Created by Joseph McBride on 4/2/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Cocoa

class AutoMapperWindowController: NSWindowController, NSComboBoxDataSource {
    
    @IBOutlet weak var mapsComboBox: NSComboBox!
    @IBOutlet weak var nodesLabel: NSTextField!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var mapView: MapView!
    @IBOutlet weak var mapLevelLabel: NSTextField!
    
    private var context:GameContext?
    private var maps:[MapInfo] = []
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
        
        if let mapsFolder = context?.pathProvider.mapsFolder() {
            self.nodesLabel.stringValue = "Loading Maps ..."
            self.loadMaps(mapsFolder)
        }
    }
    
    func setContext(context:GameContext) {
        self.context = context
        
//        self.context?.globalVars.changed.subscribeNext { (obj:AnyObject?) -> Void in
//            
//            if self.mapView == nil {
//                return
//            }
//            
//            if let changed = obj as? Dictionary<String, String> {
//                if changed.keys.first == "roomid" {
//                    
//                    var roomId = changed["roomid"]
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        self.mapView.currentRoomId = roomId
//                    })
//                }
//            }
//        }
    }
    
    func findCurrentRoom(){
        
    }
    
    func loadMaps(mapsFolder:String) {
        
        { () -> [MapMetaResult] in
            
            return self.mapLoader.loadFolder(mapsFolder)
            
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
            
            self.nodesLabel.stringValue = ""
            
            self.mapsComboBox.reloadData()
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
        let selectedMap = self.maps[idx]
        
        if let mapsFolder = context?.pathProvider.mapsFolder() {
            
            let file = mapsFolder.stringByAppendingPathComponent(selectedMap.file)
            
            self.nodesLabel.stringValue = "Loading ..."
            
            let start = NSDate()
            
            self.loadMap({ () -> MapLoadResult in
                return self.mapLoader.load(file)
            }, { (result) -> () in
                
                let diff = NSDate().timeIntervalSinceDate(start)
                
                println("diff: \(diff)")
                
                switch result {
                    
                case let .Success(zone):
                    
                    self.context?.mapZone = zone
                    
                    self.findCurrentRoom()
                    
                    var rect = zone.mapSize(0, padding: 100.0)
                    
                    self.mapView?.setFrameSize(rect.size)
                    self.mapView?.setZone(zone, rect: rect)
                    
                    let roomCount = zone.rooms.count
                    
                    self.nodesLabel.stringValue = "Map Rooms: \(roomCount)"
                    
                case let .Error(error):
                    self.nodesLabel.stringValue = "Error loading map: \(error)"
                }
            })
        }
    }
    
    // MARK - NSComboBoxDataSource
    
    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
        return self.maps.count
    }
    
    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
        let map = self.maps[index]
        return "\(map.id). \(map.name)"
    }
    
    func loadMap <R> (
        backgroundClosure: () -> R,
        _ mainClosure: (result: R) -> ())
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let result = backgroundClosure()
            dispatch_async(dispatch_get_main_queue(), {
                mainClosure(result: result)
            })
        }
    }
}

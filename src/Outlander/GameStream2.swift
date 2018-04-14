//
//  GameStream2.swift
//  Outlander
//
//  Created by Joseph McBride on 6/9/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class GameStream2 : NSObject {

    let server:GameServer
    let tokenizer:StreamTokenizer
    let streamer:TokenStreamer

    public var connected:((String)->())
    public var disconnected:(()->())
    public var text:(([TextTag])->())
    public var variable:((String, String)->())
    public var clearStream:((String)->())
    public var roundtime:((Roundtime)->())
    public var spell:((String)->())
    public var vitals:((Vitals)->())

    class func newInstance(_ context:GameContext) -> GameStream2 {
        return GameStream2(context)
    }

    init(_ context:GameContext) {
        self.server = GameServer(context: context)
        self.tokenizer = StreamTokenizer()
        self.streamer = TokenStreamer()

        self.connected = { _ in }
        self.disconnected = {}

        self.text = { _ in }
        self.variable = { _ in }
        self.clearStream = { _ in }
        self.roundtime = { _ in }
        self.spell = { _ in }
        self.vitals = { _ in }

        super.init()

        self.streamer.text = { self.text($0) }
        self.streamer.variable = { self.variable($0.key, $0.value) }
        self.streamer.clearStream = { self.clearStream($0) }
        self.streamer.roundtime = { self.roundtime($0) }
        self.streamer.spell = { self.spell($0) }
        self.streamer.vitals = { self.vitals($0) }
    }

    func connect(key:String, host:String, port:Int) {
        self.server.connect(key, toHost: host, onPort: UInt16(port)).subscribeNext({xml in
            if let rawXml = xml as? String {
                let tokens = self.tokenizer.tokenize(rawXml)
                self.streamer.stream(tokens)
            }
        }, completed: {
            self.unsubscribe()
            self.disconnected()
        })
    }

    func disconnect() {
        self.server.disconnect()
        self.unsubscribe()
    }

    func send(command:String) {
        self.server.sendCommand(command)
    }

    private func unsubscribe() {
    }
}

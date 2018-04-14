//
//  GameServer2.swift
//  Outlander
//
//  Created by Joseph McBride on 3/21/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

open class Connection : NSObject, StreamDelegate {
    
    fileprivate var inputStream: InputStream?
    fileprivate var outputStream: OutputStream?
    
    func connect(_ host:String, port:Int) {
        print("connecting...")
        
        Stream.getStreamsToHost(withName: host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        self.inputStream?.delegate = self
        self.outputStream?.delegate = self
        
        self.inputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream?.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
        self.inputStream?.open()
        self.outputStream?.open()
    }
    
    open func writeData(_ str:String) {
        let test = str + "\r\n"
        print("writing: \(test)")
        let data = test.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        self.outputStream?.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength: data.count)
    }
    
    open func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        print("stream event: \(eventCode)")
        
        switch(eventCode) {
        case Stream.Event.openCompleted:
            print("Stream opened")
        case Stream.Event.hasBytesAvailable:
            print("bytes")
            readBytes(stream)
        case Stream.Event.errorOccurred:
            print("error")
        case Stream.Event.endEncountered:
            print("end")
            stream.close()
            stream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        default:
            print("unknown event!")
        }
    }
    
    fileprivate func readBytes(_ theStream:Stream){
        if (theStream == inputStream) {
            
            var buffer = [UInt8](repeating: 0, count: 1024)
            
            while inputStream!.hasBytesAvailable {
                let length = inputStream!.read(&buffer, maxLength: buffer.count)
                if(length > 0) {
                    let data = NSString(bytes: buffer, length: length, encoding: String.Encoding.utf8.rawValue)
                    print("recieved data: \(String(describing: data))")
                }
            }
        }
    }
}

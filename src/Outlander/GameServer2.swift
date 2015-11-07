//
//  GameServer2.swift
//  Outlander
//
//  Created by Joseph McBride on 3/21/15.
//  Copyright (c) 2015 Joe McBride. All rights reserved.
//

import Foundation

public class Connection : NSObject, NSStreamDelegate {
    
    private var inputStream: NSInputStream?
    private var outputStream: NSOutputStream?
    
    func connect(host:String, port:Int) {
        print("connecting...")
        
        NSStream.getStreamsToHostWithName(host, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        self.inputStream?.delegate = self
        self.outputStream?.delegate = self
        
        self.inputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        self.outputStream?.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
        self.inputStream?.open()
        self.outputStream?.open()
    }
    
    public func writeData(str:String) {
        let test = str + "\r\n"
        print("writing: \(test)")
        let data = test.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
        self.outputStream?.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
    }
    
    public func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        print("stream event: \(eventCode)")
        
        switch(eventCode) {
        case NSStreamEvent.OpenCompleted:
            print("Stream opened")
        case NSStreamEvent.HasBytesAvailable:
            print("bytes")
            readBytes(stream)
        case NSStreamEvent.ErrorOccurred:
            print("error")
        case NSStreamEvent.EndEncountered:
            print("end")
            stream.close()
            stream.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        default:
            print("unknown event!")
        }
    }
    
    private func readBytes(theStream:NSStream){
        if (theStream == inputStream) {
            
            var buffer = [UInt8](count: 1024, repeatedValue: 0)
            
            while inputStream!.hasBytesAvailable {
                let length = inputStream!.read(&buffer, maxLength: buffer.count)
                if(length > 0) {
                    let data = NSString(bytes: buffer, length: length, encoding: NSUTF8StringEncoding)
                    print("recieved data: \(data)")
                }
            }
        }
    }
}
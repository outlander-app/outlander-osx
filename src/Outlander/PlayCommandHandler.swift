//
//  PlayCommandHandler.swift
//  Outlander
//
//  Created by Joseph McBride on 3/17/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation

@objc
class PlayCommandHandler : NSObject, CommandHandler, NSSoundDelegate {

    var sounds:[NSSound] = []
    var fileSystem:FileSystem

    class func newInstance(fileSystem:FileSystem) -> PlayCommandHandler {
        return PlayCommandHandler(fileSystem: fileSystem)
    }

    init(fileSystem:FileSystem) {
        self.fileSystem = fileSystem
    }

    func canHandle(command: String) -> Bool {
        return command.lowercaseString.hasPrefix("#play")
    }

    func handle(command: String, withContext: GameContext) {
        let text = command
            .substringFromIndex(command.startIndex.advancedBy(5))
            .stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

        guard text.characters.count > 0 else {
            removeStoppedSounds()
            return
        }

        if text == "clear" || text == "stop" {
            clear()
        } else {
            play(text, context: withContext)
        }

        removeStoppedSounds()
    }

    func clear() {
        for index in sounds.count.stride(through: 1, by: -1) {
            let sound = sounds[index - 1]
            if sound.playing {
                sound.stop()
            }
        }
    }

    func play(soundFile:String, context:GameContext) {

        var file = soundFile

        if !self.fileSystem.fileExists(file) {

            file = context.pathProvider.soundsFolder().stringByAppendingPathComponent(file)

            if !self.fileSystem.fileExists(file) {
                return
            }
        }
        
        if let sound = NSSound(contentsOfFile: file, byReference: false) {
            sound.setName(file)
            sound.delegate = self
            sounds.append(sound)
            sound.play()
        }
    }

    func removeStoppedSounds() {
        for index in sounds.count.stride(through: 1, by: -1) {
            let sound = sounds[index - 1]
            if !sound.playing {
                sounds.removeAtIndex(index - 1)
            }
        }
    }

    func sound(sound: NSSound, didFinishPlaying flag: Bool) {
        if let idx = sounds.indexOf(sound) {
            sound.delegate = nil
            sounds.removeAtIndex(idx)
        }
    }
}

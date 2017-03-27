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

    class func newInstance(_ fileSystem:FileSystem) -> PlayCommandHandler {
        return PlayCommandHandler(fileSystem: fileSystem)
    }

    init(fileSystem:FileSystem) {
        self.fileSystem = fileSystem
    }

    func canHandle(_ command: String) -> Bool {
        return command.lowercased().hasPrefix("#play")
    }

    func handle(_ command: String, with withContext: GameContext) {
        let text = command
            .substring(from: command.characters.index(command.startIndex, offsetBy: 5))
            .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

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
        for index in stride(from: sounds.count, through: 1, by: -1) {
            let sound = sounds[index - 1]
            if sound.isPlaying {
                sound.stop()
            }
        }
    }

    func play(_ soundFile:String, context:GameContext) {

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
        for index in stride(from: sounds.count, through: 1, by: -1) {
            let sound = sounds[index - 1]
            if !sound.isPlaying {
                sounds.remove(at: index - 1)
            }
        }
    }

    func sound(_ sound: NSSound, didFinishPlaying flag: Bool) {
        if let idx = sounds.index(of: sound) {
            sound.delegate = nil
            sounds.remove(at: idx)
        }
    }
}

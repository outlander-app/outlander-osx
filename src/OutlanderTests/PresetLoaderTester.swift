//
//  PresetLoaderTester.swift
//  Outlander
//
//  Created by Joseph McBride on 1/20/17.
//  Copyright © 2017 Joe McBride. All rights reserved.
//

import Foundation
import Nimble
import Quick

class PresetLoaderTester : QuickSpec {

    override func spec() {

        let fileSystem = StubFileSystem()
        let context = GameContext()
        let loader = PresetLoader(context: context, fileSystem: fileSystem)

        func presetAtIndex(index: Int) -> ColorPreset {
            var sorted = context.presets.sort { $0.0 < $1.0 }
            return sorted[index].1
        }

        describe("presets") {

            beforeEach {
                context.presets.removeAll()
            }

            it("loads preset") {
                fileSystem.fileContents = "#preset {concentration} {#000040}"

                loader.load()

                expect(context.presets.count).to(equal(1))
                let preset = presetAtIndex(0)
                expect(preset.name).to(equal("concentration"))
                expect(preset.color).to(equal("#000040"))
                expect(preset.presetClass).to(equal(""))
            }

            it("loads preset with class") {
                fileSystem.fileContents = "#preset {concentration} {#000040} {a class}"

                loader.load()

                expect(context.presets.count).to(equal(1))
                let preset = presetAtIndex(0)
                expect(preset.name).to(equal("concentration"))
                expect(preset.color).to(equal("#000040"))
                expect(preset.presetClass).to(equal("a class"))
            }

            it("loads preset with dual color") {
                fileSystem.fileContents = "#preset {concentration} {#000040,#000055} {something}"

                loader.load()

                expect(context.presets.count).to(equal(1))
                let preset = presetAtIndex(0)
                expect(preset.name).to(equal("concentration"))
                expect(preset.color).to(equal("#000040"))
                expect(preset.backgroundColor).to(equal("#000055"))
                expect(preset.presetClass).to(equal("something"))
            }

            it("loads muliple presets") {
                fileSystem.fileContents = "#preset {concentration} {#000040}\n#preset {health} {#400000} {a class}"

                loader.load()

                expect(context.presets.count).to(equal(2))
                var preset = presetAtIndex(0)
                expect(preset.name).to(equal("concentration"))
                expect(preset.color).to(equal("#000040"))
                expect(preset.presetClass).to(equal(""))

                preset = presetAtIndex(1)
                expect(preset.name).to(equal("health"))
                expect(preset.color).to(equal("#400000"))
                expect(preset.presetClass).to(equal("a class"))
            }

            it("saves preset") {
                let preset = ColorPreset("health", "#400000", "")
                context.presets[preset.name] = preset

                loader.save()

                expect(fileSystem.fileContents).to(equal("#preset {health} {#400000}\n"))
            }

            it("saves multiple presets") {
                var preset = ColorPreset("concentration", "#000051", "")
                context.presets[preset.name] = preset

                preset = ColorPreset("health", "#400000", "something")
                context.presets[preset.name] = preset

                loader.save()

                expect(fileSystem.fileContents).to(equal("#preset {concentration} {#000051}\n#preset {health} {#400000} {something}\n"))
            }
        }
    }
}

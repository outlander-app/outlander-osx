//
//  MapZoneTester.swift
//  Outlander
//
//  Created by Joseph McBride on 11/2/18.
//  Copyright © 2018 Joe McBride. All rights reserved.
//

import Foundation

import Foundation
import Nimble
import Quick

class MapZoneTester : QuickSpec {

    func createNode(id:String, name:String, descriptions: [String]) -> MapNode {
            return MapNode(
                id: id,
                name: name,
                descriptions: descriptions,
                notes: nil,
                color: nil,
                position: MapPosition(x: 1, y: 2, z: 1),
                arcs: [])
    }

    func createNode(id:String, name:String = "room") -> MapNode {
            return MapNode(
                id: id,
                name: name,
                descriptions: [
                    "Tall stalks of ripe corn tower high on either side of the thoroughfare",
                    "The silhouettes of tall stalks of ripe corn tower high on either side of the thoroughfare"
                ],
                notes: nil,
                color: nil,
                position: MapPosition(x: 1, y: 2, z: 1),
                arcs: [])
    }

    override func spec() {

        var mapZone:MapZone = MapZone("1", "Testing")

        describe("map zone") {

            beforeEach() {
                mapZone = MapZone("1", "Testing")
            }

            it("finds adjacent room with unique names / descriptions") {
                let node1 = self.createNode("a", name: "room a", descriptions: [
                    "room a"
                ])
                node1.arcs.append(MapArc(exit: "east", move: "east", destination: "b", hidden: false))
                mapZone.addRoom(node1)

                let node2 = self.createNode("b", name: "room b", descriptions: [
                    "room b"
                ])
                node2.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                node2.arcs.append(MapArc(exit: "east", move: "east", destination: "c", hidden: false))
                mapZone.addRoom(node2)

                let node3 = self.createNode("c", name: "room c", descriptions: [
                    "room c"
                ])
                node3.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                mapZone.addRoom(node3)

                let foundRoom = mapZone.findRoomFuzyFrom(
                    "a",
                    name: node2.name,
                    description: node2.descriptions[0],
                    exits: ["east", "west"])
                expect(foundRoom).toNot(beNil())
                expect(foundRoom!.id).to(equal(node2.id))
            }

            it("finds adjacent room with unique names / descriptions with unknown exits") {
                let node1 = self.createNode("a", name: "room a", descriptions: [
                    "room a"
                ])
                node1.arcs.append(MapArc(exit: "east", move: "east", destination: "b", hidden: false))
                mapZone.addRoom(node1)

                let node2 = self.createNode("b", name: "room b", descriptions: [
                    "room b"
                ])
                node2.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                node2.arcs.append(MapArc(exit: "east", move: "east", destination: "c", hidden: false))
                mapZone.addRoom(node2)

                let node3 = self.createNode("c", name: "room c", descriptions: [
                    "room c"
                ])
                node3.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                mapZone.addRoom(node3)

                let foundRoom = mapZone.findRoomFuzyFrom(
                    "a",
                    name: node2.name,
                    description: node2.descriptions[0],
                    exits: [])
                expect(foundRoom).toNot(beNil())
                expect(foundRoom!.id).to(equal(node2.id))
            }

            it("finds reverse adjacent room with unique names / descriptions with unknown exits") {
                let node1 = self.createNode("a", name: "room a", descriptions: [
                    "room a"
                ])
                node1.arcs.append(MapArc(exit: "east", move: "east", destination: "b", hidden: false))
                mapZone.addRoom(node1)

                let node2 = self.createNode("b", name: "room b", descriptions: [
                    "room b"
                ])
                node2.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                node2.arcs.append(MapArc(exit: "east", move: "east", destination: "c", hidden: false))
                mapZone.addRoom(node2)

                let node3 = self.createNode("c", name: "room c", descriptions: [
                    "room c"
                ])
                node3.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                mapZone.addRoom(node3)

                let foundRoom = mapZone.findRoomFuzyFrom(
                    "c",
                    name: node2.name,
                    description: node2.descriptions[0],
                    exits: [])
                expect(foundRoom).toNot(beNil())
                expect(foundRoom!.id).to(equal(node2.id))
            }

            it("finds adjacent room with only one exit") {
                let node1 = self.createNode("a")
                node1.arcs.append(MapArc(exit: "east", move: "east", destination: "b", hidden: false))
                mapZone.addRoom(node1)

                let node2 = self.createNode("b")
                node2.arcs.append(MapArc(exit: "west", move: "west", destination: "a", hidden: false))
                node2.arcs.append(MapArc(exit: "east", move: "east", destination: "b", hidden: false))
                mapZone.addRoom(node2)

                let node3 = self.createNode("c")
                node3.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                mapZone.addRoom(node3)

                let foundRoom = mapZone.findRoomFuzyFrom(
                    "a",
                    name: node2.name,
                    description: node2.descriptions[0],
                    exits: ["east", "west"])
                expect(foundRoom).toNot(beNil())
                expect(foundRoom!.id).to(equal(node2.id))
            }

            it("finds adjacent room with two exits, based on available exits") {
                let node1 = self.createNode("a")
                node1.arcs.append(MapArc(exit: "east", move: "east", destination: "b", hidden: false))
                mapZone.addRoom(node1)

                let node2 = self.createNode("b")
                node2.arcs.append(MapArc(exit: "west", move: "west", destination: "a", hidden: false))
                node2.arcs.append(MapArc(exit: "east", move: "east", destination: "c", hidden: false))
                mapZone.addRoom(node2)

                let node3 = self.createNode("c")
                node3.arcs.append(MapArc(exit: "west", move: "west", destination: "b", hidden: false))
                mapZone.addRoom(node3)

                let currentExits = ["west"]

                let foundRoom = mapZone.findRoomFuzyFrom(
                    "b",
                    name: node2.name,
                    description: node2.descriptions[0],
                    exits: currentExits)
                expect(foundRoom).toNot(beNil())
                expect(foundRoom!.id).to(equal(node3.id))
            }
        }
    }
}

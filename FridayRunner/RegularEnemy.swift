//
//  RegularEnemy.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/21/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class RegularEnemy: Character {
    var aimWaypoint: Waypoint!
    var path: NSArray!
    var currentAim: CGPoint!
    var currentAimIndex: Int = 0
    
    init(gameScene: GameScene, position: CGPoint) {
        super.init(gameScene: gameScene, texture: SKTexture(imageNamed: "player.png"))
        super.position = position
        super.name = "enemy"
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.texture!.size())
        self.physicsBody!.allowsRotation = false
        
        self.physicsBody!.categoryBitMask = GameScene.O_CHARACTER | GameScene.O_ANOTHERCH
        self.physicsBody!.collisionBitMask = GameScene.O_OBSTACLE
        self.physicsBody!.contactTestBitMask = GameScene.O_OBSTACLE
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func findWay() {
        self.aimWaypoint = gameScene.getNearestWaypoint(self.position)
        self.path = gameScene.pathfinder.findPathFromStart(self.position, toTarget: aimWaypoint.point)
        
        println(path)
        //println(path.count)
    }
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        
        if(path != nil) {
        if(currentAim == nil && currentAimIndex + 1 < path.count) {
            currentAim = path[currentAimIndex++].CGPointValue()
        }
        
        if(currentAim != nil) {
            let dist: CGFloat = sqrt(pow(position.x - currentAim.x, 2) + pow(position.y - currentAim.y, 2))
            let angle: CGFloat = atan2(currentAim.y - position.y, currentAim.x - position.x)
    
            self.physicsBody!.velocity = CGVector(dx: cos(angle) * 25 * 2, dy: sin(angle) * 25 * 2)
            
            if(dist < 2) {
                println("Reached a waypoint.")
                
                currentAim = nil
                self.physicsBody!.velocity.dx = 0
                self.physicsBody!.velocity.dy = 0
                
                if(currentAimIndex == path.count - 1) {
                    if(aimWaypoint.next != nil) {
                        gameScene.printList(aimWaypoint)
                        println("Getting the next node of the way.")
                        aimWaypoint = aimWaypoint.next
                        self.path = gameScene.pathfinder.findPathFromStart(self.position, toTarget: aimWaypoint.point)
                        println(aimWaypoint.description)
                        println(path)
                        currentAimIndex = 0
                    } else {
                        println("Looking for a new waypoint.")
                        self.aimWaypoint = gameScene.getNearestWaypoint(self.position)
                        gameScene.printList(aimWaypoint)
                        self.path = gameScene.pathfinder.findPathFromStart(self.position, toTarget: aimWaypoint.point)
                        currentAimIndex = 0
                        currentAim = nil
                    }
                }
            }
        }
        }
    }
}
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
        super.init(gameScene: gameScene, texture: SKTexture(imageNamed: "regular_enemy.png"))
        //super.xScale = 0.5
        //super.yScale = 0.5
        super.position = position
        super.name = "enemy"
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: CGSize(width: 24, height: 24))
        self.physicsBody!.allowsRotation = false
        
        self.physicsBody!.categoryBitMask = GameScene.O_CHARACTER | GameScene.O_ANOTHERCH
        self.physicsBody!.collisionBitMask = GameScene.O_OBSTACLE
        self.physicsBody!.contactTestBitMask = GameScene.O_OBSTACLE
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collidedWith(obj: SKNode) {
        //println("next")
        nextWaypoint()
    }
    
    func drawWay() {
        return
        removeDrawnWay()
        if path == nil {return}
        for point in path {
            var node = SKShapeNode(rectOfSize: gameScene.pathfinder.tileSize)
            node.name = "way"
            node.position = point.CGPointValue()
            //node.position.x += 48
            //node.position.y -= 24
            node.position.y += 5
            node.strokeColor = SKColor.redColor()
            gameScene.world.addChild(node)
        }
    }
    
    func removeDrawnWay() {
        gameScene.world.enumerateChildNodesWithName("way") {
            node, stop in
            node.removeFromParent()
        }
    }
    
    func findWay() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            self.aimWaypoint = self.gameScene.getNearestWaypoint(super.position)
            self.gameScene.checks = 0
            self.path = self.gameScene.pathfinder.findPathFromStart(super.position, toTarget: self.aimWaypoint.point)
            
            self.drawWay()
            
            dispatch_async(dispatch_get_main_queue()) {
                println("Checks of tiles: \(self.gameScene.checks)")
                println(self.aimWaypoint.description)
                println(self.path) 
            }
        }
    }
    
    func nextWaypoint() {
        if(currentAimIndex + 1 < path.count) {
            currentAim = path[currentAimIndex++].CGPointValue()
        }
    }
    
    var cursingPlayer: Bool = false
    
    func dist(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
    
    func canSee(obj: SKSpriteNode) -> Bool {
        var current: CGPoint = position
        let step: CGFloat = 10
        let angle: CGFloat = atan2(obj.position.y - position.y, obj.position.x - position.x)
        println(angle * 180/CGFloat(M_PI))
        
        while dist(current, p2: obj.position) > step {
            var node = gameScene.world.nodeAtPoint(current)
            if(node.name == "obstacle") {
                println("not visible")
                return false
            }
            
            current.x += step * sin(angle)
            current.y += step * cos(angle)
        }
        
        return true
    }
    
    let SKIP_UNVEAL_TICKS: Int = 6
    var skippedUnvealTicks: Int = 0
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        
        var distToPlayer = sqrt(pow(position.x - gameScene.player.position.x, 2) + pow(position.y - gameScene.player.position.y, 2))
        
        //println(canSee(gameScene.player))
        
        if(distToPlayer < 100 && canSee(gameScene.player)) {
            cursingPlayer = true
            let angle: CGFloat = atan2(gameScene.player.position.y - position.y, gameScene.player.position.x - position.x)
            self.physicsBody!.velocity = CGVector(dx: cos(angle) * 25 * 2, dy: sin(angle) * 25 * 2)
        } else {
            if(cursingPlayer) {
                cursingPlayer = false
                findWay()
            } else if(path == nil) {
                return
            }
        
        if(currentAim == nil) {
            nextWaypoint()
        }

        if(currentAim != nil) {
            let dist: CGFloat = sqrt(pow(position.x - currentAim.x, 2) + pow(position.y - currentAim.y, 2))
            let angle: CGFloat = atan2(currentAim.y - position.y, currentAim.x - position.x)
    
            self.physicsBody!.velocity = CGVector(dx: cos(angle) * 25 * 2, dy: sin(angle) * 25 * 2)
            
            if(dist < 1) {
                println("Reached a waypoint.")
                
                currentAim = nil
                self.physicsBody!.velocity.dx = 0
                self.physicsBody!.velocity.dy = 0
                
                if(currentAimIndex == path.count - 1) {
                    if(aimWaypoint.next != nil) {
                        gameScene.printList(aimWaypoint)
                        println("Getting the next node of the way.")
                        aimWaypoint = aimWaypoint.next
                        gameScene.checks = 0
                        self.path = gameScene.pathfinder.findPathFromStart(self.position, toTarget: aimWaypoint.point)
                        println("Checks of tiles: \(gameScene.checks)")
                        println(aimWaypoint.description)
                        println(path)
                        currentAimIndex = 0
                        
                        drawWay()
                    } else {
                        println("Looking for a new waypoint.")
                        self.aimWaypoint = gameScene.getNearestWaypoint(self.position)
                        gameScene.printList(aimWaypoint)
                        gameScene.checks = 0
                        self.path = gameScene.pathfinder.findPathFromStart(self.position, toTarget: aimWaypoint.point)
                        println("Checks of tiles: \(gameScene.checks)")
                        currentAimIndex = 0
                        currentAim = nil
                        
                        drawWay()
                    }
                }
            }
            }
        }
    }
}
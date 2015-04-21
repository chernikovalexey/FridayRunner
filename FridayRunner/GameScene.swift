//
//  GameScene.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/18/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var world: JSTileMap!
    var player: Player!
    var fingerPoint: CGPoint!
    
    static let O_OBSTACLE: UInt32 = 0x1 << 0
    static let O_CHARACTER: UInt32 = 0x1 << 1
    static let O_ANOTHERCH: UInt32 = 0x1 << 2
    static let O_BULLET: UInt32 = 0x1 << 3
    
    override func didMoveToView(view: SKView) {
        self.world = JSTileMap(named: "layout map.tmx")
        self.addChild(world)
        
        // hide bb layer
        world.layerNamed("BB").hidden = true
        
        self.player = Player(gameScene: self, position: CGPoint(x: 124.0, y: world.mapSize.height / 2 * 48 - 48 / 2 + 100))
        world.addChild(player)
        
        var enemy: RegularEnemy = RegularEnemy(gameScene: self, position: CGPoint(x: 124.0, y: world.mapSize.height / 2 * 48 + 50))
        world.addChild(enemy)
       
        placeCameraAboveEntity(player)
        
        self.physicsWorld.contactDelegate = self
        
        var count: Int = 0
        
        // Possible bug: false size of layer identification
        // layer.map.mapSize may cause an error
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        for x in 0...Int(world.layerNamed("BB").map.mapSize.width) {
            for y in 0...Int(world.layerNamed("BB").map.mapSize.height) {
                var tile: SKSpriteNode! = world.layerNamed("BB").tileAtCoord(CGPoint(x: x, y: y))
                
                if(tile != nil) {
                    tile.name = "obstacle"
                    
                    tile.physicsBody = SKPhysicsBody(texture: tile.texture!, size: CGSize(width: 96, height: 48))
                    tile.physicsBody!.dynamic = false
                    
                    tile.physicsBody!.categoryBitMask = GameScene.O_OBSTACLE
                    
                    ++count
                }
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var collider, victim: SKNode!
        
        println("got a collision: \(contact.bodyA.categoryBitMask), \(contact.bodyB.categoryBitMask)")
        
        if(contact.bodyA.categoryBitMask > contact.bodyB.categoryBitMask) {
            collider = contact.bodyA.node
            victim = contact.bodyB.node
        } else {
            collider = contact.bodyB.node
            victim = contact.bodyA.node
        }
        
        if(collider is GameObject) {
            (collider as! GameObject).collidedWith(victim)
        }
        
        if(victim is GameObject) {
            (victim as! GameObject).hitBy(collider)
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
    
    func placeCameraAboveEntity(entity: SKSpriteNode) {
         world.position = CGPointMake(-(entity.position.x - self.size.width / 2), -(entity.position.y - self.size.height / 2))
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch: UITouch = touches.first as! UITouch
    
        if(touch.tapCount == 1) {
            self.fingerPoint = touch.locationInNode(world)
        } else if(touch.tapCount >= 2) {
            player.shoot(touch.locationInNode(world))
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch: UITouch = touches.first as! UITouch
        self.fingerPoint = touch.locationInNode(world)
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.fingerPoint = nil
    }
   
    override func update(currentTime: CFTimeInterval) {
        player.update(currentTime)
        world.enumerateChildNodesWithName("bullet") {
            node, stop in
            var bullet = node as! Bullet
            bullet.update(currentTime)
        }
    }
}

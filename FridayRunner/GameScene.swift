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
    
    static let E_WALLS: UInt32 = 1 << 0
    static let E_GAMEOBJ: UInt32 = 1 << 1
    
    override func didMoveToView(view: SKView) {
        self.world = JSTileMap(named: "layout map.tmx")
        self.addChild(world)
        
        
        
        // hide bb layer
        world.layerNamed("BB").hidden = true
        
        self.player = Player(gameScene: self, position: CGPoint(x: 124.0, y: world.mapSize.height / 2 * 48 - 48 / 2 + 100))
        world.addChild(player)
       
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
                    tile.physicsBody = SKPhysicsBody(texture: tile.texture!, size: CGSize(width: 96, height: 48))
                    //tile.physicsBody!.categoryBitMask = GameScene.E_WALLS
                    //tile.physicsBody!.collisionBitMask = GameScene.E_WALLS
                    //tile.physicsBody!.contactTestBitMask = GameScene.E_GAMEOBJ
                    //tile.physicsBody!.dynamic = false
                    //tile.physicsBody!.restitution = 0.1
                    //tile.physicsBody!.friction = 0.4
                    //tile.physicsBody!.mass = 10.0
                    tile.physicsBody!.dynamic=false
                    //tile.zPosition = player.zPosition
                    tile.physicsBody!.affectedByGravity=false
                    //tile.removeFromParent()
                    //world.addChild(tile)
                    
                    ++count
                }
            }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        println("contact")
        if(contact.bodyA.node is Player || contact.bodyB.node is Player) {
            println("player collision")
        }
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        
    }
    
    func placeCameraAboveEntity(entity: SKSpriteNode) {
         world.position = CGPointMake(-(entity.position.x - self.size.width / 2), -(entity.position.y - self.size.height / 2))
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        var touch: UITouch = touches.first as! UITouch
        self.fingerPoint = touch.locationInNode(world)
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
    }
}

//
//  Player.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/19/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class Player: GameObject {
    init(gameScene: GameScene, position: CGPoint) {
        super.init(gameScene: gameScene, texture: SKTexture(imageNamed: "player.png"))
        super.position = position
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: CGSize(width: 48, height: 48))
        //self.physicsBody!.categoryBitMask = GameScene.E_GAMEOBJ
        //self.physicsBody!.collisionBitMask = GameScene.E_GAMEOBJ
        //self.physicsBody!.contactTestBitMask = GameScene.E_WALLS
        //self.physicsBody!.mass = 1.2
        //self.physicsBody!.friction = 1.0
        //self.physicsBody!.angularDamping = 10.0
        //self.physicsBody!.linearDamping = 30.0
        //self.physicsBody!.restitution = 10.0
        self.physicsBody!.allowsRotation = false
        //self.physicsBody!.usesPreciseCollisionDetection = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var sx, sy: CGFloat!
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        
        let speed: CGFloat = 4.475
        
        //var sx: CGFloat!
        //var sy: CGFloat!
        
        if(gameScene.fingerPoint == nil) {
            sx = 0.0
            sy = 0.0
        } else {
            let angle: CGFloat = atan2(gameScene.fingerPoint.y - position.y, gameScene.fingerPoint.x - position.x)
            
            sx = cos(angle) * speed
            sy = sin(angle) * speed
        }
        
        let accX = -velocity.dx * groundFriction + sx
        let accY = -velocity.dy * groundFriction + sy
        
        velocity.dx = accX
        velocity.dy = accY
        
        //self.runAction(SKAction.moveBy(CGVector(dx: sx, dy: sy), duration: 1.025))
        self.physicsBody!.velocity = CGVector(dx: velocity.dx * speed * 5, dy: velocity.dy * speed * 5)
        //self.physicsBody!.applyImpulse(velocity)
        
        if(velocity.dx != 0.0 || velocity.dy != 0.0) {
            gameScene.placeCameraAboveEntity(self)
        }
    }
}
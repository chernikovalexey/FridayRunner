//
//  Player.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/19/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class Player: Character {
    init(gameScene: GameScene, position: CGPoint) {
        super.init(gameScene: gameScene, texture: SKTexture(imageNamed: "player.png"))
        super.position = position
        super.name = "player"
        
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.texture!.size())
        self.physicsBody!.allowsRotation = false
        
        self.physicsBody!.categoryBitMask = GameScene.O_CHARACTER
        self.physicsBody!.collisionBitMask = GameScene.O_OBSTACLE | GameScene.O_ANOTHERCH
        self.physicsBody!.contactTestBitMask = GameScene.O_OBSTACLE
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shoot(at: CGPoint) {
        println("coords: \(position.x), \(position.y)")
        let angle: CGFloat = atan2(at.y - position.y, at.x - position.x)
        var bullet: Bullet = Bullet(gameScene: gameScene, owner: self, position: CGPoint(x: self.position.x, y: self.position.y), direction: CGVector(dx: cos(angle), dy: sin(angle)))
        
        gameScene.world.addChild(bullet)
    }
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        
        let speed: CGFloat = 4.475
        
        var sx, sy: CGFloat!
        
        if(gameScene.fingerPoint == nil) {
            sx = 0.0
            sy = 0.0
        } else {
            let angle: CGFloat = atan2(gameScene.fingerPoint.y - position.y, gameScene.fingerPoint.x - position.x)
            
            sx = cos(angle) * speed
            sy = sin(angle) * speed
        }
        
        let accX = -self.physicsBody!.velocity.dx * groundFriction + sx
        let accY = -self.physicsBody!.velocity.dy * groundFriction + sy
        
        self.physicsBody!.velocity.dx = accX * speed * 5
        self.physicsBody!.velocity.dy = accY * speed * 5
        
        if(accX != 0.0 || accY != 0.0) {
            gameScene.placeCameraAboveEntity(self)
        }
    }
}
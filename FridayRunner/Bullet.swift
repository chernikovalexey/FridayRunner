//
//  Bullet.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/20/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class Bullet: GameObject {
    var direction: CGVector! = CGVector(dx: 0.0, dy: 0.0)
    var owner: GameObject!
    
    init(gameScene: GameScene, owner: GameObject, position: CGPoint, direction: CGVector) {
        super.init(gameScene: gameScene, texture: SKTexture(imageNamed: "simple_bullet"))
        super.position = position
        super.name = "bullet"
        
        self.owner = owner
        self.direction = direction
            
        self.physicsBody = SKPhysicsBody(texture: self.texture!, size: self.texture!.size())
        self.physicsBody!.allowsRotation = false
        self.physicsBody!.usesPreciseCollisionDetection = true
        
        self.physicsBody!.categoryBitMask = GameScene.O_BULLET
        self.physicsBody!.collisionBitMask = GameScene.O_OBSTACLE
        self.physicsBody!.contactTestBitMask = GameScene.O_OBSTACLE
    }
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(currentTime: CFTimeInterval) {
        let speed: CGFloat = 20.0
        let dx: CGFloat = direction.dx * speed * 5
        let dy: CGFloat = direction.dy * speed * 5
        self.physicsBody!.velocity = CGVector(dx: dx, dy: dy)
    }
    
    override func collidedWith(obj: SKNode) {
        if(self.owner != obj) {
            self.removeFromParent()
        
            if(obj is Player) {
                (obj as! Player).damage(10)
            }
        }
    }
}
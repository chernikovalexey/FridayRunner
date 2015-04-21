//
//  RegularEnemy.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/21/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class RegularEnemy: Character {
    init(gameScene: GameScene, position: CGPoint) {
        super.init(gameScene: gameScene, texture: SKTexture(imageNamed: "regular_enemy.png"))
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
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
    }
}
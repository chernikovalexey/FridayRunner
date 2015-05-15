//
//  Player.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/19/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class Player: Character {
    var skippedTick: Bool = false
    var state: Int = 5
    
    let angles: [CGFloat] = [0, 45, 90, 135, 180, 225, 270, 315]
    
    var textures: [CGFloat: [SKTexture]] = [CGFloat: [SKTexture]]()
    
    init(gameScene: GameScene, position: CGPoint) {
        var atlas: SKTextureAtlas = SKTextureAtlas(named: "player")
        
        for angle in angles {
            textures[angle] = [SKTexture]()
            for i in [5, 4, 3, 2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 8, 7, 6] {
                textures[angle]!.append(atlas.textureNamed("p\(Int(angle))_\(i)"))
            }
        }
        
        var t: SKTexture = textures[270]!.first!
        super.init(gameScene: gameScene, texture: t)
        super.position = position
        super.name = "player"
        
        super.shadowCastBitMask = 1;
        super.lightingBitMask = 1;
        super.shadowedBitMask = 1;
        
        self.physicsBody = SKPhysicsBody(circleOfRadius: 12, center: CGPoint(x: 0, y: -16))
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
    
    var runningAction: Bool = false
    var fixedAngleInDegrees: CGFloat = 270
    
    override func update(currentTime: CFTimeInterval) {
        super.update(currentTime)
        
        let speed: CGFloat = 5.475
        
        var sx, sy: CGFloat!
        sx = 0
        sy = 0
        
        if(gameScene.startFingerPoint != nil && gameScene.currentFingerPoint != nil) {
            let angle: CGFloat = atan2(gameScene.currentFingerPoint.y - gameScene.startFingerPoint.y, gameScene.currentFingerPoint.x - gameScene.startFingerPoint.x)
            
            sx = cos(angle) * speed
            sy = sin(angle) * speed
            
            var degAngle = angle * 180 / CGFloat(M_PI)
            
            if(degAngle < 0) {
                degAngle += 360
            }
            
            var prevAngle: CGFloat = self.fixedAngleInDegrees
            var minDiff: CGFloat = CGFloat.max
            for a in angles {
                var diff: CGFloat = abs(a - degAngle)
                if(diff < minDiff) {
                    minDiff = diff
                    self.fixedAngleInDegrees = a
                }
            }
            
            if(prevAngle != fixedAngleInDegrees) {
                self.removeAllActions()
                self.texture = textures[fixedAngleInDegrees]!.first!
                runningAction = false
            }
            
            if(!runningAction) {
                runningAction = true
                var move: SKAction = SKAction.animateWithTextures(textures[fixedAngleInDegrees]!, timePerFrame: 0.05, resize: true, restore: true)
                self.runAction(SKAction.repeatActionForever(move))
            }
        }
        
        let accX = -self.physicsBody!.velocity.dx * groundFriction + sx
        let accY = -self.physicsBody!.velocity.dy * groundFriction + sy
        
        self.physicsBody!.velocity.dx = accX * speed * 5
        self.physicsBody!.velocity.dy = accY * speed * 5
        
        if(accX != 0.0 || accY != 0.0) {
            gameScene.placeCameraAboveObject(self)
        }
    }
}
//
//  GameObject.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/19/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class GameObject: SKSpriteNode {
    var canMove: Bool! = true
    var gameScene: GameScene!
    var velocity: CGVector! = CGVector(dx: 0.0, dy: 0.0)
    
    let groundFriction: CGFloat! = 1.0 / 1000.0
    
    init(gameScene: GameScene, texture: SKTexture) {
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.gameScene = gameScene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(currentTime: CFTimeInterval) {
        
    }
}
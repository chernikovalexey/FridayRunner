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
    
    let groundFriction: CGFloat! = 1.0 / 1000.0
    
    init(gameScene: GameScene, sprite: SKSpriteNode) {
        super.init(texture: sprite.texture, color: sprite.color, size: sprite.texture!.size())
        self.gameScene = gameScene
    }
    
    init(gameScene: GameScene, texture: SKTexture) {
        super.init(texture: texture, color: UIColor.clearColor(), size: texture.size())
        self.gameScene = gameScene
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("")
    }
    
    func update(currentTime: CFTimeInterval) {
    }
    
    func collidedWith(obj: SKNode) {
    }
    
    func hitBy(obj: SKNode) {
    }
}
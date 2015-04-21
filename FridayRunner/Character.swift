//
//  Character.swift
//  FridayRunner
//
//  Created by Oleksii Chernikov on 4/21/15.
//  Copyright (c) 2015 Oleksii Chernikov. All rights reserved.
//

import Foundation

class Character: GameObject {
    var health: Int = 120
    
    func damage(points: Int) {
        health -= points
        
        if(health <= 0) {
            println("Character dies!")
            self.removeFromParent()
        }
    }
}
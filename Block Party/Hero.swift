//
//  Dot.swift
//  dot
//
//  Created by Qi Feng Huang on 1/3/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//


import SpriteKit


class Hero : SKSpriteNode{
    
    //rec is the playable scene
    init(spriteTexture: SKTexture){
        
        super.init(texture: spriteTexture, color: UIColor.clearColor(), size: spriteTexture.size())
        name = "hero"
        zPosition = 75
        
        //create physics body
        let physicsbody = SKPhysicsBody(rectangleOfSize: self.size)
        physicsbody.usesPreciseCollisionDetection = true
        
        physicsbody.restitution = 0
        physicsbody.friction = 0
        physicsbody.categoryBitMask = PhysicsCategory.Hero
        physicsbody.collisionBitMask = PhysicsCategory.Boundary
        physicsbody.contactTestBitMask = PhysicsCategory.Enemy | PhysicsCategory.Charm
        self.physicsBody = physicsbody
    }
    
    required init(coder aDecoder : NSCoder){
        fatalError("NSCoding not supported")
    }
    

}

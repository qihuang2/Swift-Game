//
//  Charm.swift
//  Block Party
//
//  Created by Qi Feng Huang on 2/15/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

//collectable

class Charm: SKSpriteNode {
    
    let worth:Int //how much to add to score when collected
    
    static let moveSpeed:NSTimeInterval = 2
    
    init(spriteTexture:SKTexture, worth:Int){
        self.worth = worth
        super.init(texture: spriteTexture, color: UIColor.clearColor(), size: spriteTexture.size())
        zPosition = 75
        setScale(0.6)           //make a bit smaller
        
        //set up physics body
        let physicsbody = SKPhysicsBody(rectangleOfSize: CGSize(width: self.size.width, height: self.size.height))
        
        physicsbody.restitution = 0
        physicsbody.friction = 0
        physicsbody.categoryBitMask = PhysicsCategory.Charm
        physicsbody.collisionBitMask = PhysicsCategory.None
        physicsbody.contactTestBitMask = PhysicsCategory.None
        self.physicsBody = physicsbody

    }
    
    required init(coder aDecoder : NSCoder){
        fatalError("NSCoding not supported")
    }
    
    
    func getMoveAction()->SKAction{
        let move = SKAction.moveToY(-self.size.height, duration: Charm.moveSpeed)
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([move,remove])
    }
    
    func getPosition(sceneSize: CGSize)->CGPoint{
        return CGPoint(x: randomPoint(min: 0, max: sceneSize.width), y: sceneSize.height + self.size.height)
    }
}
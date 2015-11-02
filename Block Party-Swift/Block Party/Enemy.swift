//
//  Enemy.swift
//  dot
//
//  Created by Qi Feng Huang on 1/8/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

enum SideOfScene: Int{
    case Right  = 0
    case Left
    case Top
    case Bottom
}

class EnemyCircle: SKSpriteNode {
    private static var horizontalSpeed:NSTimeInterval = 2
    private static var verticalSpeed:NSTimeInterval = 1.5
    let spawnLocation:SideOfScene
   
    init(spriteTexture:SKTexture, spwanLocation: SideOfScene){
        spawnLocation = spwanLocation
        super.init(texture: spriteTexture, color: UIColor.clearColor(), size: spriteTexture.size())
        zPosition = 75
        setScale(0.6)
        
        //create physics body
        let physicsbody = SKPhysicsBody(circleOfRadius: self.size.width / 2)
        
        physicsbody.restitution = 0
        physicsbody.friction = 0
        physicsbody.categoryBitMask = PhysicsCategory.Enemy
        physicsbody.collisionBitMask = PhysicsCategory.None
        physicsbody.contactTestBitMask = PhysicsCategory.None
        self.physicsBody = physicsbody
    }
    
    required init(coder aDecoder : NSCoder){
        fatalError("NSCoding not supported")
    }
    
    func getMoveSpeed()->NSTimeInterval{
        if self.spawnLocation == .Right || self.spawnLocation == .Left {
            return EnemyCircle.horizontalSpeed
        }
        else {
            return EnemyCircle.verticalSpeed
        }
    }
    
    //where enemy spawns
    static func getPosition(sceneSize:CGSize, circle: EnemyCircle)->CGPoint{
        let position:CGPoint
        switch circle.spawnLocation{
        case .Top:
            position = CGPoint(x: randomPoint(min: 0, max: sceneSize.width), y: sceneSize.height + circle.size.height)
            break
        case .Bottom:
            position = CGPoint(x: randomPoint(min: 0, max: sceneSize.width), y: -circle.size.height)
            break
        case .Left:
            position = CGPoint(x: -circle.size.width, y: randomPoint(min: 0, max: sceneSize.height))
            break
        case .Right:
            position = CGPoint(x: sceneSize.width + circle.size.width, y: randomPoint(min: 0, max: sceneSize.height))
        }
        return position
    }
    
    //make new enemies move faster
    static func makeMovementFaster(){
        if EnemyCircle.horizontalSpeed > 1{
            EnemyCircle.horizontalSpeed -= 0.1
            EnemyCircle.verticalSpeed -= 0.06
            
        }
    }
    
    //where enemy moves
    static func getMoveAction(sceneSize:CGSize, circle: EnemyCircle)->SKAction{
        let removeAction = SKAction.removeFromParent()
        let moveSpeed = circle.getMoveSpeed()
        let moveAction:SKAction
        switch circle.spawnLocation{
        case .Top:
            moveAction = SKAction.moveToY(-circle.size.height, duration: moveSpeed)
            break
        case .Bottom:
            moveAction = SKAction.moveToY(sceneSize.height + circle.size.height, duration: moveSpeed)
            break
        case .Left:
            moveAction = SKAction.moveToX(sceneSize.width + circle.size.width, duration: moveSpeed)
            break
        case .Right:
            moveAction = SKAction.moveToX(-circle.size.width, duration: moveSpeed)
        }
        return SKAction.sequence([moveAction, removeAction])
    }
}


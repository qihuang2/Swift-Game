//
//  Hero.m
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#import "Hero.h"
#import "Constants.h"

@implementation Hero

-(instancetype)initWithTexture:(SKTexture *)texture{
    //sprite has a clear color over it and takes on the size of the texture
    self = [super initWithTexture:texture color: [UIColor clearColor] size:texture.size];
    
    self.name = @"hero";
    self.zPosition = 75;
    
    //create physics body
    SKPhysicsBody* physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    physicsBody.usesPreciseCollisionDetection = true;
    
    //collision won't cause hero to move slower
    physicsBody.restitution = 0;
    physicsBody.friction = 0;
    
    //Set physics category to HERO
    physicsBody.categoryBitMask = HERO;
    
    //Hero collisdes with Boundary; can't move past boundary
    physicsBody.collisionBitMask = BOUNDARY;
    
    //Can come into contact with charm and enemy
    physicsBody.contactTestBitMask = ENEMY | CHARM;
    self.physicsBody = physicsBody;
    
    return self;
}


@end

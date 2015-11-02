//
//  Charm.m
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#import "Charm.h"
#import "Constants.h"

@implementation Charm

//how fast charm moves across scene
static const NSTimeInterval MOVEMENT_SPEED = 2;

-(instancetype)init:(SKTexture *)texture worth:(int)worth parentSceneSize:(CGSize)size{
    //init with texture
    self = [super initWithTexture:texture color:[UIColor clearColor] size:texture.size];
    
    //set member variables
    self.worth = worth;
    self.zPosition = 75;
    
    //make charm smaller
    [self setScale:0.6];
    
    //create rectangular physics body
    SKPhysicsBody* physicsbody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
    
    //won't slow down when hit hero
    physicsbody.restitution = 0;
    physicsbody.friction = 0;
    
    //sets body type to CHARM
    physicsbody.categoryBitMask = CHARM;
    
    //charm won't collide with anything; HERO will do the collision checking
    physicsbody.collisionBitMask = NONE;
    physicsbody.contactTestBitMask = NONE;
    self.physicsBody = physicsbody;
    
    //set spawn location: top of scene
    [self setSpawnPosition: size];
    
    return self;
}

+(NSTimeInterval)getMovementSpeed{
    return MOVEMENT_SPEED;
}

-(SKAction*)getMovementAction{
    //moves to bottom side of scene and remove from parent
    SKAction* move = [SKAction moveToY:-self.size.height duration:MOVEMENT_SPEED];
    SKAction* remove = [SKAction removeFromParent];
    return [SKAction sequence:@[move, remove]];
}


-(void)setSpawnPosition:(CGSize)parentSceneSize{
    //set position at top of scene at random x position
    self.position = CGPointMake(randomPoint(0, parentSceneSize.width), self.size.height + parentSceneSize.height);
}
@end

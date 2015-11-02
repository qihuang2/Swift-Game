//
//  Enemy.m
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#import "Enemy.h"
#import "Constants.h"


@implementation Enemy

//how fast the enemy moves across parent scene
//horizontal move speed is slower than vertical
//horizontal speed won't drop lower than 1 sec
static NSTimeInterval horizontalMoveSpeed = 2;
static NSTimeInterval verticalMoveSpeed = 1.5;

-(instancetype)init:(SKTexture *)texture sceneSize:(CGSize)size spawnLocation: (SideOfScene) side {
    //sets texture
    self = [super initWithTexture:texture color:[UIColor clearColor] size:texture.size];
    
    //set memeber variables
    self.spawnLocation = side;
    self.parentSceneSize = size;
    
    //set position depending on spawnLocation
    [self setStartPosition];
    [self setScale:0.6]; //make a bit smaller
    
    //create circular physics body
    SKPhysicsBody* physicBody = [SKPhysicsBody bodyWithCircleOfRadius:self.size.width / 2];
    
    //won't move slower when come into contact with other objects
    physicBody.restitution = 0;
    physicBody.friction = 0;
    
    //enemy does not collide with anything; HERO will do the collision checking
    physicBody.categoryBitMask = ENEMY;
    physicBody.collisionBitMask = NONE;
    physicBody.contactTestBitMask = NONE;
    self.physicsBody = physicBody;
    
    return self;
    
    
}

-(void)setStartPosition{
    switch (self.spawnLocation) {
        case Right:
            //right side of scene with random y position
            self.position = CGPointMake(self.parentSceneSize.width + self.size.width, randomPoint(0, self.parentSceneSize.height));
            break;
        case Left:
            //left side of the scene with random y position
            self.position = CGPointMake( -self.size.width + self.size.width, randomPoint(0, self.parentSceneSize.height));
            break;
        case Top:
            //top side of scene with random x position
            self.position = CGPointMake(randomPoint(0, self.parentSceneSize.width), self.parentSceneSize.height + self.size.height);
            break;
        case Bottom:
            //bottom side of scene with random x position
            CGPointMake(randomPoint(0, self.parentSceneSize.width), -self.size.height);
            break;
    }
}

+(void) makeMovementFaster{
    //horizontalSpeed won't go lower than 1 sec
    if (horizontalMoveSpeed > 1) {
        horizontalMoveSpeed -= 0.1;
        verticalMoveSpeed -= 0.06;
    }
}

+(NSTimeInterval)horizontalMoveSpeed{
    return horizontalMoveSpeed;
}

+(NSTimeInterval)verticalMoveSpeed{
    return verticalMoveSpeed;
}

//return horizontal speed if spawned at left or right or vertical speed if spawned at top of bottom
-(NSTimeInterval)getMovementSpeed{
    return (self.spawnLocation == Left || self.spawnLocation == Right) ? horizontalMoveSpeed : verticalMoveSpeed;
}



-(SKAction*) getMovementAction{
    SKAction* removeAction = [SKAction removeFromParent];
    SKAction* moveAction;
    //set moveAction ; moveAction moves enemy to opposide side of spawn location and removes it
    switch (self.spawnLocation) {
        case Right: //move to left side
            moveAction = [SKAction moveToX:-self.size.width duration:[self getMovementSpeed]];
            break;
        case Left: //move to right side
            moveAction = [SKAction moveToX: self.parentSceneSize.width + self.size.width duration:[self getMovementSpeed]];
            break;
        case Top: //move to bottom side
            moveAction = [SKAction moveToY:-self.size.height duration:[self getMovementSpeed]];
            break;
        case Bottom: //move to top
            moveAction = [SKAction moveToY:self.parentSceneSize.height + self.size.height duration:[self getMovementSpeed]];
            break;
    }
    //action that moves to opposide side of spawn location and removes from parent
    return [SKAction sequence: @[moveAction,removeAction]];
}

@end

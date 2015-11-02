//
//  Enemy.h
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//side of scene
//using this to determine which side enemy spawns on
typedef enum{
    Right = 0,
    Left = 1,
    Top = 2,
    Bottom = 3
} SideOfScene;

@interface Enemy : SKSpriteNode

@property (nonatomic) const SideOfScene spawnLocation;
@property (nonatomic) CGSize parentSceneSize;

//init Enemy
//@param texture - texture of our Enemy Sprite
//@param size - parent scene size
//@param spawnLocation - side where to spawn enemy
-(instancetype)init: (SKTexture*) texture sceneSize: (CGSize) size spawnLocation: (SideOfScene) side;

//set start position of enemy when they spawn
-(void) setStartPosition;

//make enemy move faster
//horizontalSpeed will never fall below 1 sec
+(void)makeMovementFaster;

//get the movement action of the enemy
-(SKAction*) getMovementAction;


//return which speed to use according to which side enemy spawned on
//left, right = horizontal
//top, bottom = vertical
//horizontal speed is slower than vertical speed
-(NSTimeInterval)getMovementSpeed;


@end

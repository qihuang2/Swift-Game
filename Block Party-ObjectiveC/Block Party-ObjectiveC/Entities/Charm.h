//
//  Charm.h
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface Charm : SKSpriteNode

//how many points the hero recieves when hero collects the charm
//different color charms ahave different worth
@property (nonatomic) int worth;

//init charm
//@param texture - charm's sprite texture
//@param worth - how many points the charm is worth when collected
//@param size - size of parent node; used to set spawn position
-(instancetype)init:(SKTexture*) texture worth:(int) worth parentSceneSize: (CGSize) size;

//how fast the chamr moves
//only vertical speed because heros only spawn in top side
+(NSTimeInterval)getMovementSpeed;

//moves movement action that moves charm to bottom of scene
-(SKAction*)getMovementAction;

//sets start position of charm : top of scene with random x position
//@param parentSceneSize - size of parent scen; used to set spawn position at top of scene
-(void)setSpawnPosition:(CGSize) parentSceneSize;

@end

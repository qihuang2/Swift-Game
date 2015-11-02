//
//  GameScene.h
//  Block Party-Objective_C
//

//  Copyright (c) 2015 hackathon. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

//State of the game
//Determines if we are currently playing the game
typedef enum {
    PLAYING = 0,
    MAIN_MENU = 1,
    LEVEL_SELECT = 2,
    LOSE = 3,
    WIN = 4
}GameModes;


@class Hero;

@interface GameScene : SKScene <SKPhysicsContactDelegate>

//Hero of the game
@property (nonatomic) Hero* hero;

//layer contains the current score and best score labels
@property (nonatomic) SKNode* scoreHudLayer;

//contains enemies, charms, and the hero
@property (nonatomic) SKNode* characterLayer;

//contains the game's buttons
@property (nonatomic) SKNode* buttonLayer;

//node is shown when game over
@property (nonatomic) SKNode* gameOverNode;

//tutorial of how the game is played
@property (nonatomic) SKNode* directionsNode;

//the games current state
@property (nonatomic) GameModes gameState;

//label showing current score
@property (nonatomic) SKLabelNode* currentScoreLabel;

//label showing best score
@property (nonatomic) SKLabelNode* bestScoreLabel;

//keeps track of score
@property (nonatomic) NSInteger score;

//keeps track of best score
@property (nonatomic) NSInteger bestScore;

//atlas containing our sprite textures
@property (nonatomic) SKTextureAtlas* spriteAtlas;

//init scene with size
-(instancetype)initWithSize:(CGSize)size;

//init hero, sets its position, and adds to characterLayer
-(void)setUpHero;

//set up labels showing tutorial and add to direction layer
-(void) setUpGameDirections;

-(void)didBeginContact:(SKPhysicsContact *)contact;

//creates the boundaries for the game
-(void)createPhysicsBound;

//start spawning enemy and charms
-(void)startSpawning;

//set up best score and current score labels
-(void)setUpGameScores;

//set game state to game over and show game over nodes
-(void)showGameOverNode;

//restarts game
-(void)restart;

//get status of game
-(GameModes)getGameStatus;


@end

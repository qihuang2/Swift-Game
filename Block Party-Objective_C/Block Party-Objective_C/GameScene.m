//
//  GameScene.m
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright (c) 2015 hackathon. All rights reserved.
//

#import "GameScene.h"
#import "Constants.h"
#import "Hero.h"
#import "Charm.h"
#import "Enemy.h"

@implementation GameScene


-(instancetype)initWithSize:(CGSize)size{
    self = [super initWithSize:size];
    
    //create empty SKNodes to group other objects
    self.scoreHudLayer = [SKNode node];
    self.characterLayer = [SKNode node];
    self.buttonLayer = [SKNode node];
    self.gameOverNode = [SKNode node];
    self.directionsNode = [SKNode node];
    
    //set gameState to main menu
    self.gameState = MAIN_MENU;
    
    //create score labels using font "markerfelt-wide"
    self.currentScoreLabel = [SKLabelNode labelNodeWithFontNamed: @"markerfelt-wide"];
    self.bestScoreLabel  = [SKLabelNode labelNodeWithFontNamed: @"markerfelt-wide"];
    
    //set initial score for game
    self.score = 0;
    
    //check if there is already a best score saved. If not, store 0 as best score
    self.bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"highScore"];
    
    //our images will be stored in an atlas called "characters"
    self.spriteAtlas = [SKTextureAtlas atlasNamed:@"characters"];
    
    //set gravity to 0. no gravity in this game
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    
    return self;
}

-(void)didMoveToView:(SKView *)view {
    self.backgroundColor = [UIColor blackColor];
    
    //set up the game scene
    [self setUpHero];
    [self setUpGameDirections];
    [self createPhysicsBound];
    [self setUpGameScores];
    
    self.characterLayer.zPosition = 75;
    
    //add the nodes for the game to scene
    [self addChild:self.characterLayer];
    [self addChild:self.directionsNode];
    [self addChild:self.scoreHudLayer];

}


-(void)setUpHero{
    //create hero and set start position to middle of scene
    self.hero = [[Hero alloc]initWithTexture:[self.spriteAtlas textureNamed:@"hero"]];
    self.hero.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    
    //add to characterLayer
    [self.characterLayer addChild:self.hero];
}

-(void)setUpGameDirections{
    //set up labels with direction on how to play the game
    //set font, color, text, and position
    SKLabelNode* directionLabel = [SKLabelNode labelNodeWithFontNamed:@"markerfelt-wide"];
    directionLabel.fontColor = [UIColor whiteColor];
    directionLabel.fontSize = 50;
    directionLabel.text = @"TOUCH TO START";
    directionLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.65);
    
    SKLabelNode* directionLabel2 = [SKLabelNode labelNodeWithFontNamed:@"markerfelt-wide"];
    directionLabel2.fontColor = [UIColor redColor];
    directionLabel2.fontSize = 60;
    directionLabel2.text = @"DON'T LET GO";
    directionLabel2.position = CGPointMake(self.size.width / 2, directionLabel.position.y - directionLabel.frame.size.height * 1.5);
    
    //add to direction node
    [self.directionsNode addChild:directionLabel];
    [self.directionsNode addChild:directionLabel2];
}

//Used to store charm objects that need to be removed from scene
NSMutableArray* charmsToRemove = nil;
//called when hero collides with something
-(void)didBeginContact:(SKPhysicsContact *)contact{
    
    //if array not initialized, initialize it
    if (charmsToRemove == nil) charmsToRemove = [NSMutableArray array];
    
    //only run if in game
    if (self.gameState == PLAYING) {
        //get object hero collided with
        SKPhysicsBody* other = (contact.bodyA.categoryBitMask == HERO) ? contact.bodyB : contact.bodyA;
        
        //if collided with enemy, go to game over scene
        if(other.categoryBitMask == ENEMY){
            [other.node removeAllActions];
            [self showGameOverNode];
        }
        //if charm, add to charmsToRemoveArray to remove later
        else if (other.categoryBitMask == CHARM){
            [charmsToRemove addObject: (Charm*) other.node];
        }
    }
}

//check charmsToRemoveArray to remove them from scene and add points to current score
-(void)didSimulatePhysics{
    //make sure array exists and it isn't already empty
    if (charmsToRemove != nil && charmsToRemove.count) {
        
        //for each charm, remove form parent and increment our score
        for (Charm* c in charmsToRemove) {
            
            [c removeFromParent];
            self.score += c.worth;
            
            //change score label
            self.currentScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            
            //every 30 points, we make enemy move faster
            if (self.score != 0 && self.score % 30 == 0) [Enemy makeMovementFaster];
        }
        //empty out array
        [charmsToRemove removeAllObjects];
    }
}

//where players finger is currently
CGPoint currentPoint;
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //if in main menu and touch starts, start the game
    if (self.gameState == MAIN_MENU) {
        self.gameState = PLAYING; //change to playing state
        UITouch* touch = [touches anyObject]; //get UITouch object that contains where the finger touched scene
        
        //if touch is nil, return
        if (touch == nil) return;
        
        currentPoint = [touch locationInNode:self]; //get location finger touched scene
        
        //if player touched screen, remove tutorial and start spawning entities
        [self.directionsNode removeFromParent];
        [self startSpawning];
    }
    //currently in lose scene, then touch restarts game
    else if (self.gameState == LOSE) [self restart];
}


//if player moves finger, update heros position
-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //move hero only if in playing state
    if (self.gameState == PLAYING) {
        UITouch* touch = [touches anyObject]; //get object with info on where player touched scene
        //return if invalid touch
        if (touch == nil) return;
        
        CGPoint position = [touch locationInNode:self]; //get location where player touched scene
        
        //how much the player's finger moved
        CGPoint changeInPosition = CGPointMake(position.x - currentPoint.x, position.y - currentPoint.y);
        
        //update current position
        currentPoint = position;
        
        //change hero position depending on the change in positon of the player's finger
        self.hero.position = CGPointMake(self.hero.position.x + changeInPosition.x, self.hero.position.y + changeInPosition.y);
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.gameState == PLAYING) {
        //if player lets go while playing, game over
        self.gameState = LOSE;
        [self showGameOverNode];
    }
}

//boundaries for game
-(void)createPhysicsBound{
    
    //create sknode to hold boundary
    SKNode* bounds = [SKNode node];
    bounds.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    bounds.physicsBody.categoryBitMask = BOUNDARY;
    bounds.physicsBody.collisionBitMask = NONE;
    
    //no friction or restitution
    bounds.physicsBody.restitution = 0;
    bounds.physicsBody.friction = 0;
    
    //add to character layer so hero can interact with it
    [self.characterLayer addChild:bounds];
}


-(void)startSpawning{
    //time before each enemy spawn
    SKAction* waitAction1 = [SKAction waitForDuration:0.25];
    SKAction* spawnEnemyAction = [SKAction runBlock: ^(void){[self spawnEnemy];}];
    
    //spawn enemy, wait, repeat
    SKAction* repeatEnemySpawn = [SKAction repeatActionForever:[SKAction sequence:@[spawnEnemyAction,waitAction1]]];
    
    //spawn enemy forever
    [self.characterLayer runAction:repeatEnemySpawn];
    
    //time before each charm spawn
    SKAction* waitAction2 = [SKAction waitForDuration: 1.2];
    SKAction* spawnCharmAction = [SKAction runBlock: ^(void){[self spawnCharm];}];
    
    //spawn charm, wait, repeat
    SKAction* repeatCharmSpawn = [SKAction repeatActionForever:[SKAction sequence:@[spawnCharmAction,waitAction2]]];
    
    //spawn charm forever
    [self.characterLayer runAction:repeatCharmSpawn];
}



-(void)spawnEnemy{
    SideOfScene side = (int)arc4random_uniform(4); //side to spawn enemy
    
    //init enemy
    Enemy* enemy = [[Enemy alloc]init:[self.spriteAtlas textureNamed:@"enemy"]
                            sceneSize: self.size spawnLocation:side];
    //set name to enemy
    enemy.name = @"enemy";
    
    //add to characterLayer
    [self.characterLayer addChild:enemy];
    
    //run enemy movement action
    [enemy runAction: [enemy getMovementAction]];
}

-(void)spawnCharm{
    //how many points charm will give
    int worth = arc4random_uniform(3); //random worth
    
    //get correct texture for corresponding worth
    SKTexture* texture = [self.spriteAtlas textureNamed:[NSString stringWithFormat:@"charm%i", worth]];
    Charm* charm = [[Charm alloc]init:texture worth:worth+2 parentSceneSize:self.size];
    
    charm.name = @"charm";
    
    //add to characterLayer
    [self.characterLayer addChild:charm];
    
    //run movement action
    [charm runAction:[charm getMovementAction]];
}

-(void)setUpGameScores{
    //set size, position, font color, zposition, and text of currentScoreLabel
    self.currentScoreLabel.fontColor = [UIColor whiteColor];
    self.currentScoreLabel.fontSize = 100;
    self.currentScoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
    self.currentScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.currentScoreLabel.name = @"time node";
    self.currentScoreLabel.position = CGPointMake(self.size.width/2, self.size.height * 0.8);
    self.currentScoreLabel.zPosition = -50; //will be shown behind hero and charms
    
    //set size, position, font color, zposition, and text of bestScoreLabel
    self.bestScoreLabel.fontColor = [UIColor redColor];
    self.bestScoreLabel.fontSize = 80;
    self.bestScoreLabel.text = [NSString stringWithFormat:@"Best : %ld", (long)self.bestScore];
    self.bestScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.bestScoreLabel.position = CGPointMake(self.size.width/2, self.currentScoreLabel.position.y + self.currentScoreLabel.frame.size.height * 1.5);
    self.bestScoreLabel.zPosition = -50; //will be shown behind hero and charms
    
    //add to scoreHudLayer
    [self.scoreHudLayer addChild:self.currentScoreLabel];
    [self.scoreHudLayer addChild:self.bestScoreLabel];
}

-(void)showGameOverNode{
    //run if gameovernode doesnt have parent; if there is a parent, already in game over state
    if (self.gameOverNode.parent == nil){
        
        self.gameState = LOSE; //change to game over state
        
        [self.characterLayer removeAllActions]; //stop spawning
        self.characterLayer.alpha = 0.3; //fade out the characterlater
        
        self.gameOverNode.alpha = 0; //hide gameOverLayer; fade in later
        self.gameOverNode.zPosition = 80; //put above everything on scene
        
        //remove movement actions of enemies
        [self.characterLayer enumerateChildNodesWithName:@"enemy" usingBlock:^(SKNode* node, BOOL* stop){[node removeAllActions];}];
        
        //remove movement actions of charms
        [self.characterLayer enumerateChildNodesWithName:@"charm" usingBlock:^(SKNode* node, BOOL* stop){[node removeAllActions];}];
        
        //update highScore if current score better
        if (self.score > self.bestScore) {
            [[NSUserDefaults standardUserDefaults]setInteger:self.score forKey: @"highScore"];
            self.bestScoreLabel.text = [NSString stringWithFormat:@"NEW Best : %ld", (long)self.score];
            
        }
        
        //move currentScoreLabel to gameOverNode
        [self.currentScoreLabel removeFromParent];
        self.currentScoreLabel.zPosition = 100;
        self.currentScoreLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.6);
        [self.gameOverNode addChild:self.currentScoreLabel];
        
        //move bestScoreLabel to gameOverNode
        [self.bestScoreLabel removeFromParent];
        self.bestScoreLabel.zPosition = 100;
        self.bestScoreLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.75);
        [self.gameOverNode addChild:self.bestScoreLabel];
        
        //directions on how to play again
        SKLabelNode* retryLabel = [SKLabelNode labelNodeWithFontNamed:@"markerfelt-wide"];
        retryLabel.fontColor = [UIColor whiteColor];
        retryLabel.fontSize = 70;
        retryLabel.position = CGPointMake(self.size.width / 2, self.size.height * 0.25);
        retryLabel.text = @"TAP TO RESTART";
        
        [self.gameOverNode addChild:retryLabel];
        
        [self addChild:self.gameOverNode];
        [self.gameOverNode runAction:[SKAction fadeInWithDuration:0.25]];
    }
}


-(void)restart{
    [self.scene removeFromParent];
    SKTransition* trans = [SKTransition crossFadeWithDuration:0.75]; //action for presenting new scene
    GameScene* newScene = [GameScene sceneWithSize:self.size]; //create new GameScene
    newScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:newScene transition:trans]; //presents new scene using trans
}

-(GameModes)getGameStatus{
    return self.gameState;
}

@end

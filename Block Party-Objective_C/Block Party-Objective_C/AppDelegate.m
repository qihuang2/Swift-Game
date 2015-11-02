//
//  AppDelegate.m
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#import "AppDelegate.h"
#import "GameScene.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    //if currently playing game, go to game over scene
    //game won't run while inactive
    
    //get current skview
    SKView* currentView = (SKView*)self.window.rootViewController.view;
    if (currentView != nil) { //if it exists
        //try getting current scene
        GameScene* currentScene = (GameScene*) currentView.scene;
        if (currentScene != nil) { //if current scene is the game scene
            //if player if currently playing the game, go to game over
            if ([currentScene getGameStatus] == PLAYING) {
                [currentScene showGameOverNode];
            }
        }
        currentView.paused = YES;
    }
    
    //save all game data
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //save all game data
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //save all game data
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //try getting current SKView
    SKView* currentView = (SKView*) self.window.rootViewController.view;
    
    if (currentView != nil) {
        //if it exists, unpause the view
        currentView.paused = NO;
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    //save all game data
    [[NSUserDefaults standardUserDefaults]synchronize];
}

@end

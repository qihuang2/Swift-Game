//
//  Constants.m
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//
#import <SpriteKit/SpriteKit.h>


//generate random point between max and min
CGFloat randomPoint(CGFloat min, CGFloat max){
    return min + ((CGFloat)((float)arc4random())) / (float)(UINT32_MAX) * (max-min);
}
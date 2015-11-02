//
//  Constants.h
//  Block Party-Objective_C
//
//  Created by Qi Feng Huang on 10/31/15.
//  Copyright © 2015 hackathon. All rights reserved.
//

#ifndef Constants_h
#define Constants_h


//Physics Body Types
//Used to determine which object interacts with others
static const uint32_t NONE           = 0x1 << 0;
static const uint32_t ALL            = UINT32_MAX;
static const uint32_t BOUNDARY       = 0x1 << 1;
static const uint32_t HERO           = 0x1 << 2;
static const uint32_t CHARM          = 0x1 << 3;
static const uint32_t ENEMY          = 0x1 << 4;


//generate random point between max and min
//@param min - return value >= min
//@param max - return value <= max
CGFloat randomPoint(CGFloat min, CGFloat max);

#endif /* Constants_h */

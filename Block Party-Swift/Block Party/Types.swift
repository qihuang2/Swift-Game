//
//  Types.swift
//  Block Party
//
//  Created by Qi Feng Huang on 2/15/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None         :UInt32 = 0
    static let All          :UInt32 = UInt32.max
    static let Boundary     :UInt32 = 0b1        //1
    static let Hero         :UInt32 = 0b10       //2
    static let Charm        :UInt32 = 0b100      //4
    static let Enemy        :UInt32 = 0b1000     //8
}


func randomPoint(min min: CGFloat, max: CGFloat) -> CGFloat{
    return min + CGFloat(Float(arc4random()) / Float(UInt32.max)) * (max-min)
}


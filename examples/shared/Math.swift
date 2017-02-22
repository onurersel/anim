//
//  Math.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit


extension CGFloat {
    
    static var random: CGFloat {
        let max: UInt32 = 10000
        return CGFloat(arc4random_uniform(max)) / CGFloat(max)
    }
    
    var radian: CGFloat {
        return CGFloat.pi * self / 180.0
    }
    
    static func random(from: CGFloat, to: CGFloat) -> CGFloat {
        let diff = to-from
        return from + diff*random
    }
    
    static func random(offset: CGFloat, range: CGFloat) -> CGFloat {
        return random(from: offset-range/2.0, to: offset+range/2.0)
    }
    
}

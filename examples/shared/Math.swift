//
//  Math.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

struct DoubleRange {
    var min: Double
    var max: Double
    
    static var random01: Double {
        let max: UInt32 = 10000
        return Double(arc4random_uniform(max)) / Double(max)
    }
    
    var random: Double {
        let diff = max - min
        return min + diff * DoubleRange.random01
    }
    
}

extension Double {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension CGFloat {
    var radian: CGFloat {
        return CGFloat.pi * self / 180.0
    }
    
    func randomize(range: CGFloat) -> CGFloat {
        return self - range * 0.5 + range * DoubleRange.random01.cgFloat
    }
}




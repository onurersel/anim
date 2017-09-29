//
//  DistanceExtension.swift
//  anim
//
//  Created by Onur Ersel on 2017-09-29.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import UIKit

enum PlatformScale: CGFloat {
    case iOS = 1
    case tvOS = 3

    static var valueForPlatform: PlatformScale {
        #if os(tvOS)
            return self.tvOS
        #else
            return self.iOS
        #endif
    }
}

extension Double {
    var platform: CGFloat {
        return CGFloat(self) * PlatformScale.valueForPlatform.rawValue
    }
}

extension Float {
    var platform: CGFloat {
        return CGFloat(self) * PlatformScale.valueForPlatform.rawValue
    }
}

extension CGFloat {
    var platform: CGFloat {
        return self * PlatformScale.valueForPlatform.rawValue
    }
}

extension Int {
    var platform: CGFloat {
        return CGFloat(self) * PlatformScale.valueForPlatform.rawValue
    }
}

extension CGSize {
    var platform: CGSize {
        return CGSize(width: self.width.platform, height: self.height.platform)
    }
}

extension DoubleRange {
    var platform: DoubleRange {
        return DoubleRange(min: Double(self.min.platform), max: Double(self.max.platform))
    }
}

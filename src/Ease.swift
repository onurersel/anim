//
//  Ease.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation
#if os(iOS) || os(tvOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

/// Easing value. Stores two points for cubic easing calculation.
public struct animEase {

    /// Handle for beginning point of cubic bezier
    internal let point1: CGPoint
    /// Handle for ending point of cubic bezier
    internal let point2: CGPoint

    /// Creates a custom easing value for cubic easing calculation.
    ///
    /// - Parameters:
    ///   - point1: First handle point.
    ///   - point2: Second handle point.
    /// - Returns: Easing value.
    public static func custom(point1: CGPoint, point2: CGPoint) -> animEase {
        return animEase(point1: point1, point2: point2)
    }

    /// Converts ease value to media timing function for `ViewAnimator`.
    internal var caMediaTimingFunction: CAMediaTimingFunction {
        return CAMediaTimingFunction(controlPoints: Float(point1.x), Float(point1.y), Float(point2.x), Float(point2.y))
    }

    /// http://easings.net/#easeInSine
    public static let easeInSine        = animEase(point1: CGPoint(x: 0.47, y: 0), point2: CGPoint(x: 0.745, y: 0.715))
    /// http://easings.net/#easeOutSine
    public static let easeOutSine       = animEase(point1: CGPoint(x: 0.39, y: 0.575), point2: CGPoint(x: 0.565, y: 1))
    /// http://easings.net/#easeInOutSine
    public static let easeInOutSine     = animEase(point1: CGPoint(x: 0.445, y: 0.05), point2: CGPoint(x: 0.55, y: 0.95))

    /// http://easings.net/#easeInQuad
    public static let easeInQuad        = animEase(point1: CGPoint(x: 0.55, y: 0.085), point2: CGPoint(x: 0.68, y: 0.53))
    /// http://easings.net/#easeOutQuad
    public static let easeOutQuad       = animEase(point1: CGPoint(x: 0.25, y: 0.46), point2: CGPoint(x: 0.45, y: 0.94))
    /// http://easings.net/#easeInOutQuad
    public static let easeInOutQuad     = animEase(point1: CGPoint(x: 0.455, y: 0.03), point2: CGPoint(x: 0.515, y: 0.955))

    /// http://easings.net/#easeInCubic
    public static let easeInCubic       = animEase(point1: CGPoint(x: 0.55, y: 0.055), point2: CGPoint(x: 0.675, y: 0.19))
    /// http://easings.net/#easeOutCubic
    public static let easeOutCubic      = animEase(point1: CGPoint(x: 0.215, y: 0.61), point2: CGPoint(x: 0.355, y: 1))
    /// http://easings.net/#easeInOutCubic
    public static let easeInOutCubic    = animEase(point1: CGPoint(x: 0.645, y: 0.045), point2: CGPoint(x: 0.355, y: 1))

    /// http://easings.net/#easeInQuart
    public static let easeInQuart       = animEase(point1: CGPoint(x: 0.895, y: 0.03), point2: CGPoint(x: 0.685, y: 0.22))
    /// http://easings.net/#easeOutQuart
    public static let easeOutQuart      = animEase(point1: CGPoint(x: 0.165, y: 0.84), point2: CGPoint(x: 0.44, y: 1))
    /// http://easings.net/#easeInOutQuart
    public static let easeInOutQuart    = animEase(point1: CGPoint(x: 0.77, y: 0), point2: CGPoint(x: 0.175, y: 1))

    /// http://easings.net/#easeInQuint
    public static let easeInQuint       = animEase(point1: CGPoint(x: 0.755, y: 0.05), point2: CGPoint(x: 0.855, y: 0.06))
    /// http://easings.net/#easeOutQuint
    public static let easeOutQuint      = animEase(point1: CGPoint(x: 0.23, y: 1), point2: CGPoint(x: 0.32, y: 1))
    /// http://easings.net/#easeInOutQuint
    public static let easeInOutQuint    = animEase(point1: CGPoint(x: 0.86, y: 0), point2: CGPoint(x: 0.07, y: 1))

    /// http://easings.net/#easeInExpo
    public static let easeInExpo        = animEase(point1: CGPoint(x: 0.95, y: 0.05), point2: CGPoint(x: 0.795, y: 0.035))
    /// http://easings.net/#easeOutExpo
    public static let easeOutExpo       = animEase(point1: CGPoint(x: 0.19, y: 1), point2: CGPoint(x: 0.22, y: 1))
    /// http://easings.net/#easeInOutExpo
    public static let easeInOutExpo     = animEase(point1: CGPoint(x: 1, y: 0), point2: CGPoint(x: 0, y: 1))

    /// http://easings.net/#easeInCirc
    public static let easeInCirc        = animEase(point1: CGPoint(x: 0.6, y: 0.04), point2: CGPoint(x: 0.98, y: 0.335))
    /// http://easings.net/#easeOutCirc
    public static let easeOutCirc       = animEase(point1: CGPoint(x: 0.075, y: 0.82), point2: CGPoint(x: 0.165, y: 1))
    /// http://easings.net/#easeInOutCirc
    public static let easeInOutCirc     = animEase(point1: CGPoint(x: 0.785, y: 0.135), point2: CGPoint(x: 0.15, y: 0.86))

    /// http://easings.net/#easeInBack
    public static let easeInBack        = animEase(point1: CGPoint(x: 0.6, y: -0.28), point2: CGPoint(x: 0.735, y: 0.045))
    /// http://easings.net/#easeOutBack
    public static let easeOutBack       = animEase(point1: CGPoint(x: 0.175, y: 0.885), point2: CGPoint(x: 0.32, y: 1.275))
    /// http://easings.net/#easeInOutBack
    public static let easeInOutBack     = animEase(point1: CGPoint(x: 0.68, y: -0.55), point2: CGPoint(x: 0.265, y: 1.55))

}

extension animEase: Equatable {
    /// Checks equality between easing types.
    ///
    /// - Parameters:
    ///   - lhs: First easing value.
    ///   - rhs: Second easing value.
    /// - Returns: Return if two easing values are equal or not.
    public static func == (lhs: animEase, rhs: animEase) -> Bool {
        return lhs.point1 == rhs.point1 && lhs.point2 == rhs.point2
    }
}

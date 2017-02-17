//
//  AnimatorType.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

public extension anim {

    /// Defines which animator will be used in animation.
    public enum AnimatorType {

        /// Uses `UIViewPropertyAnimator`, only available on iOS 10.
        case propertyAnimator
        /// Uses `UIView.animate`. Available on iOS versions below 10.
        case viewAnimator
        /// Uses `NSAnimationContext`. Only available on macOS.
        case macAnimator
    }

}

/// Animator type should fulfill this protocol on each platform.
internal protocol AnimatorTypeProtocol {
    static var `default`: Self { get }
    var instance: Animator { get }
}

#if os(iOS) || os(tvOS)
extension anim.AnimatorType: AnimatorTypeProtocol {
    internal static var `default`: anim.AnimatorType {
        return .propertyAnimator
    }

    internal var instance: Animator {
        if #available(iOS 10.0, *), #available(tvOS 10.0, *), self == .propertyAnimator {
            return anim.PropertyAnimator()
        }

        return anim.ViewAnimator()
    }
}
#endif

#if os(OSX)
extension anim.AnimatorType: AnimatorTypeProtocol {
    internal static var `default`: anim.AnimatorType {
        return .macAnimator
    }

    internal var instance: Animator {
        return anim.MacAnimator()
    }
}
#endif

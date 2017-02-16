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

        /// Returns default animator for different platforms.
        static public var `default`: AnimatorType {
            #if os(iOS)
                return .propertyAnimator
            #elseif os(OSX)
                return .macAnimator
            #endif
        }

        /// Returns an instance of animator.
        public var instance: Animator {
            #if os(iOS)
            if #available(iOS 10.0, *), self == .propertyAnimator {
                return PropertyAnimator()
            } else {
                return ViewAnimator()
            }
            #elseif os(OSX)
            return MacAnimator()
            #endif
        }

    }

}

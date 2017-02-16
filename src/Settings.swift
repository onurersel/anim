//
//  Settings.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

public extension anim {

    /// Animation settings.
    public struct Settings {

        /// Delay before animation starts.
        public var delay: TimeInterval = 0
        /// Duration of animation.
        public var duration: TimeInterval = 1
        /// Easing of animation.
        public var ease: Ease = .easeOutQuint
        /// Completion block which runs after animation.
        public var completion: (Closure)?
        /// Preferred animator used for the animation.
        lazy public var preferredAnimator: AnimatorType = AnimatorType.default
        /// Enables user interactions on views while animating. Not available on macOS.
        public var isUserInteractionsEnabled: Bool = false
    }
}

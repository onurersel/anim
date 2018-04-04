//
//  Settings.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

/// Animation settings.
public struct animSettings {
    init(delay: TimeInterval = 0, duration: TimeInterval = 1, ease: animEase = .easeOutQuint, completion: (animClosure)? = nil, isUserInteractionsEnabled: Bool = false) {
        self.delay = delay
        self.duration = duration
        self.ease = ease
        self.completion = completion
        self.isUserInteractionsEnabled = isUserInteractionsEnabled
    }
    /// Delay before animation starts.
    public var delay: TimeInterval
    /// Duration of animation.
    public var duration: TimeInterval
    /// Easing of animation.
    public var ease: animEase
    /// Completion block which runs after animation.
    public var completion: (animClosure)?
    /// Preferred animator used for the animation.
    lazy public var preferredAnimator: AnimatorType = AnimatorType.default
    /// Enables user interactions on views while animating. Not available on macOS.
    public var isUserInteractionsEnabled: Bool

}

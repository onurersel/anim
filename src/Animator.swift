//
//  Animator.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

/// Type for animation controller.
public protocol Animator {

    /// Should start animation.
    ///
    /// - Parameters:
    ///   - animationClosure: Animation block which sets new values of animatable properties.
    ///   - completion: Completion block which should be called when animation is over, but not stopped.
    ///   - settings: Animation settings.
    func startAnimation(animationClosure: @escaping animClosure,
                        completion: @escaping animClosure,
                        settings: animSettings)

    /// Should stop animation before it's finished.
    func stopAnimation()
}

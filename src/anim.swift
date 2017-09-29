//
//  anim.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

#if os(iOS) || os(tvOS)
import UIKit
public typealias View = UIView
#elseif os(OSX)
import AppKit
public typealias View = NSView
#endif

/// Animation block definition.
public typealias animClosure = () -> Void

/// `anim` is an animation library written in Swift with a simple,
/// declarative API in mind.
///
///     // moves box to 100,100 with default settings
///     anim {
///         self.box.frame.origin = CGPoint(x:100, y:100)
///         }
///         // after that, waits 100 ms
///         .wait(100)
///         // moves box to 0,0 after waiting
///         .then {
///             self.box.frame.origin = CGPoint(x:0, y:0)
///         }
///         // displays message after all animations are done
///         .callback {
///             print("Just finished moving 📦 around.")
///     }
///
/// It supports a bunch of easing functions and chaining multiple animations.
/// It's a wrapper on Apple's `UIViewPropertyAnimator` on its core.
final public class anim: NSObject {

    // MARK: - Properties

    /// Default settings for animation. This is being copied to promise for each animation.
    public static var defaultSettings = animSettings()
    /// Stored animation block.
    private var animationClosure: animClosure?
    /// Animation settings.
    internal var animationSettings: animSettings

    internal var promise: Promise

    /// Values for constraint animation.
    internal var animationConstraintLayout: Constraint?
    /// Animator which is being used for animations.
    private var animator: Animator?

    // MARK: - Initializers

    /// Creates initial animation promise, with settings.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    @discardableResult
    public convenience init(_ closureWithSettings: @escaping (inout animSettings) -> (animClosure)) {
        self.init(closureWithoutProcess: closureWithSettings)
        process()
    }

    /// Creates initial animation promise.
    ///
    /// - Parameter closure: Animation block.
    @discardableResult
    public convenience init(_ closure: @escaping animClosure) {
        self.init(closureWithoutProcess: closure)
        process()
    }

    /// Creates animation promise, with settings. To be used while chaining promises.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    internal convenience init(closureWithoutProcess closure: @escaping (inout animSettings) -> (animClosure)) {
        var _settings = anim.defaultSettings
        let _closure = closure(&_settings)
        self.init(settings: _settings, closure: _closure)
    }

    /// Creates animation promise. To be used while chaining promises.
    ///
    /// - Parameter closure: Animation block.
    internal convenience init(closureWithoutProcess closure: @escaping animClosure) {
        self.init(settings: anim.defaultSettings, closure: closure)
    }

    /// Main initializer.
    ///
    /// - Parameters:
    ///   - settings: Animation settings.
    ///   - closure: Animation closure.
    internal init(settings: animSettings, closure: animClosure?) {
        promise = Promise()

        animationSettings = settings
        animationClosure = closure
    }

    // MARK: - Running promises

    /// Start processing animation promise.
    internal func process() {
        promise.state = .started
        delay()
    }

    /// Waits before starting animation block, if delay is setted.
    private func delay() {
        guard animationSettings.delay > 0 else {
            return self.run()
        }

        let delayMilliseconds: Int = Int(animationSettings.delay*1000)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delayMilliseconds)) {
            self.run()
        }
    }

    /// Runs animation block.
    private func run() {
        guard promise.state == .started else {
            return
        }

        if let layout = animationConstraintLayout {
            layout.update()
            layout.closure()
            animationClosure = layout.update
        }

        guard animationSettings.duration > 0 else {
            animationClosure?()
            return completion()
        }

        animator = animationSettings.preferredAnimator.instance
        animator?.startAnimation(animationClosure: animationClosure!,
                                 completion: completion,
                                 settings: animationSettings)
    }

    /// Animation block completion.
    private func completion() {
        guard promise.state == .started else {
            return
        }

        animationSettings.completion?()
        promise.state = .finished
        promise.next?.process()
    }

    /// Stops animation and promise chain.
    public func stop() {
        var currentAnim: anim? = self
        while let a = currentAnim?.promise.next {
            currentAnim = a
        }

        while let a = currentAnim, a.promise.state == .created {
            a.promise.state = .cancelled
            currentAnim = a.promise.prev
        }

        currentAnim?.promise.state = .cancelled
        currentAnim?.animator?.stopAnimation()
    }
}

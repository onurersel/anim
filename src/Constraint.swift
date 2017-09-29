//
//  Constraint.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

/// Constraint animation information is stored with this value.
internal struct Constraint {
    /// Animation block.
    internal var closure: animClosure
    /// Top parent of constraints to be animated.
    internal var parent: View

    /// Calls update function for layouts on different platforms.
    internal func update() {
        #if os(iOS) || os(tvOS)
            parent.layoutIfNeeded()
        #elseif os(OSX)
            parent.layoutSubtreeIfNeeded()
        #endif
    }
}

// MARK: - Initializers

extension anim {

    /// Creates initial animation promise for `NSLayoutConstraint` animations, with settings.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closureWithSettings: Exposes settings values to block, and expects returning animation block.
    @discardableResult
    public convenience init(constraintParent: View,
                            _ closureWithSettings: @escaping (inout animSettings) -> animClosure) {

        self.init(constraintParent: constraintParent, closureWithoutProcess: closureWithSettings)
        process()
    }

    /// Creates initial animation promise for `NSLayoutConstraint` animations.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    @discardableResult
    public convenience init(constraintParent: View, _ closure: @escaping animClosure) {
        self.init(constraintParent: constraintParent, closureWithoutProcess: closure)
        process()
    }

    /// Creates promise for `NSLayoutConstraint` animations, with settings. To be used while chaining promises.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Exposes settings values to block, and expects returning animation block.
    fileprivate convenience init(constraintParent: View,
                                 closureWithoutProcess closure: @escaping (inout animSettings) -> animClosure) {
        var _settings = anim.defaultSettings
        let _closure = closure(&_settings)
        self.init(settings: _settings, closure: nil)
        self.animationConstraintLayout = Constraint(closure: _closure, parent: constraintParent)
    }

    /// Creates promise for `NSLayoutConstraint` animations. To be used while chaining promises.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    fileprivate convenience init(constraintParent: View, closureWithoutProcess closure: @escaping animClosure) {
        self.init(settings: anim.defaultSettings, closure: nil)
        self.animationConstraintLayout = Constraint(closure: closure, parent: constraintParent)
    }

}

// MARK: - Chaining promises

extension anim {
    /// Creates a new promise for `NSLayoutConstraint` animations with settings, chained to the previous one.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closureWithSettings: Exposes settings values to block, and expects returning animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    public func then(constraintParent: View,
                     _ closureWithSettings: @escaping (inout animSettings) -> animClosure) -> anim {

        let nextAnim = anim(constraintParent: constraintParent, closureWithoutProcess: closureWithSettings)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a new promise for `NSLayoutConstraint` animations with settings, chained to the previous one.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    public func then(constraintParent: View, _ closure: @escaping animClosure) -> anim {
        let nextAnim = anim(constraintParent: constraintParent, closureWithoutProcess: closure)
        chain(to: nextAnim)
        return nextAnim
    }
}

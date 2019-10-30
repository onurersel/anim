//
//  Promise.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-20.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

public extension anim {

    internal struct Promise {

        /// Promise state.
        ///
        /// - created: Animation did not started yet.
        /// - started: Animation is running.
        /// - finished: Animation finished running.
        /// - cancelled: Animation cancelled before it's finished.
        internal enum State {
            case created, started, finished, cancelled
        }

        /// Reference to next promise chained to this instance.
        internal var next: anim?
        /// Reference to previous promise this instance is chained.
        weak internal var prev: anim?
        /// State of promise.
        internal var state: State = .created

    }

    /// Creates a new animation promise with settings, chained to the previous one.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    func then(_ closureWithSettings: @escaping (inout animSettings) -> animClosure) -> anim {
        let nextAnim = anim(closureWithoutProcess: closureWithSettings)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a new animation promise, chained to the previous one.
    ///
    /// - Parameter closure: Animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    func then(_ closure: @escaping animClosure) -> anim {
        let nextAnim = anim(closureWithoutProcess: closure)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a promise only waits before running next promise.
    ///
    /// - Parameter milliseconds: Milliseconds to wait.
    /// - Returns: Newly created promise.
    @discardableResult
    func wait(_ seconds: TimeInterval) -> anim {
        var settings = anim.defaultSettings
        settings.delay = seconds
        settings.duration = 0
        let nextAnim = anim(settings: settings, closure: {})
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a promise only calls a block before running next promise.
    ///
    /// - Parameter closure: Block to be runned.
    /// - Returns: Newly created promise.
    @discardableResult
    func callback(_ closure: @escaping animClosure) -> anim {
        var settings = anim.defaultSettings
        settings.delay = 0
        settings.duration = 0
        let nextAnim = anim(settings: settings, closure: closure)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Chains newly created promise to current one.
    ///
    /// - Parameter chainedAnim: Newly created promise.
    internal func chain(to chainedAnim: anim) {
        promise.next = chainedAnim
        promise.next!.promise.prev = self

        if promise.state == .finished {
            chainedAnim.process()
        }
    }

}

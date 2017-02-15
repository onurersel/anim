/**
 *  anim
 *
 *  Copyright (c) 2017 Onur Ersel. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

#if os(iOS)
import UIKit
public typealias View = UIView
#elseif os(OSX)
import AppKit
public typealias View = NSView
#endif

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
///
/// It only supports iOS 10 at the moment.
final public class anim {

    // MARK: - Types

    /// Animation block.
    public typealias Closure = () -> Void

    /// Promise state.
    ///
    /// - created: Animation did not started yet.
    /// - started: Animation is running.
    /// - finished: Animation finished running.
    /// - cancelled: Animation cancelled before it's finished.
    internal enum State {
        case created, started, finished, cancelled
    }

    // MARK: - Properties

    /// Default settings for animation. This is being copied to promise for each animation.
    public static var defaultSettings = Settings()
    /// Enables internal logging. This is for debugging.
    internal static var isLogging: Bool = false {
        didSet {
            if isLogging {
                startupTime = Date()
            }
        }
    }
    /// Starup time of anim library. Used for logging.
    fileprivate static var startupTime: Date? = nil

    /// Unique promise id.
    fileprivate let uid = UInt32(Date().timeIntervalSince1970)^arc4random_uniform(UInt32.max)
    /// Stored animation block.
    private var animationClosure: Closure?
    /// Animation settings.
    internal var animationSettings: Settings
    /// Reference to next promise chained to this instance.
    internal var next: anim? = nil
    /// Reference to previous promise this instance is chained.
    internal var prev: anim? = nil
    /// State of promise.
    internal var state: State = .created
    /// Values for constraint animation.
    internal var animationConstraintLayout: ConstraintLayout?
    /// Animator which is being used for animations.
    private var animator: Animator?

    // MARK: - Initializers

    /// Creates initial animation promise, with settings.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    @discardableResult
    public convenience init(_ closureWithSettings: @escaping (inout Settings) -> (Closure)) {
        self.init(closureWithoutProcess:closureWithSettings)
        process()
    }

    /// Creates initial animation promise.
    ///
    /// - Parameter closure: Animation block.
    @discardableResult
    public convenience init(_ closure: @escaping Closure) {
        self.init(closureWithoutProcess:closure)
        process()
    }

    /// Creates animation promise, with settings. To be used while chaining promises.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    private convenience init(closureWithoutProcess closure: @escaping (inout Settings) -> (Closure)) {
        var _settings = anim.defaultSettings
        let _closure = closure(&_settings)
        self.init(settings:_settings, closure:_closure)
    }

    /// Creates animation promise. To be used while chaining promises.
    ///
    /// - Parameter closure: Animation block.
    private convenience init(closureWithoutProcess closure: @escaping Closure) {
        self.init(settings: anim.defaultSettings, closure:closure)
    }

    /// Creates initial animation promise for `NSLayoutConstraint` animations, with settings.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closureWithSettings: Exposes settings values to block, and expects returning animation block.
    @discardableResult
    public convenience init(constraintParent: View, _ closureWithSettings: @escaping (inout Settings) -> Closure) {
        self.init(constraintParent: constraintParent, closureWithoutProcess: closureWithSettings)
        process()
    }

    /// Creates initial animation promise for `NSLayoutConstraint` animations.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    @discardableResult
    public convenience init(constraintParent: View, _ closure: @escaping Closure) {
        self.init(constraintParent: constraintParent, closureWithoutProcess: closure)
        process()
    }

    /// Creates promise for `NSLayoutConstraint` animations, with settings. To be used while chaining promises.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Exposes settings values to block, and expects returning animation block.
    private convenience init(constraintParent: View,
                             closureWithoutProcess closure: @escaping (inout anim.Settings) -> Closure) {
        var _settings = anim.defaultSettings
        let _closure = closure(&_settings)
        self.init(settings: _settings, closure:nil)
        self.animationConstraintLayout = anim.ConstraintLayout(closure: _closure, parent: constraintParent)
    }

    /// Creates promise for `NSLayoutConstraint` animations. To be used while chaining promises.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    private convenience init(constraintParent: View, closureWithoutProcess closure: @escaping Closure) {
        self.init(settings: anim.defaultSettings, closure:nil)
        self.animationConstraintLayout = anim.ConstraintLayout(closure: closure, parent: constraintParent)
    }

    /// Main initializer.
    ///
    /// - Parameters:
    ///   - settings: Animation settings.
    ///   - closure: Animation closure.
    internal init(settings: Settings, closure: Closure?) {
        self.animationSettings = settings
        self.animationClosure = closure

        log("initted")
    }

    // MARK: - Running promises

    /// Start processing animation promise.
    internal func process() {
        log("process")
        state = .started
        delay()
    }

    /// Waits before starting animation block, if delay is setted.
    private func delay() {
        log("delay")
        guard animationSettings.delay > 0 else {
            return self.run()
        }

        log("started waiting...")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(animationSettings.delay*1000))) {
            self.log("ended waiting")
            self.run()
        }
    }

    /// Runs animation block.
    private func run() {
        log("run")

        guard state == .started else {
            log("\(state), aborting")
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
        animator?.startAnimation(animationClosure: animationClosure!, completion: completion, settings: animationSettings)
    }

    /// Animation block completion.
    private func completion() {
        log("completion")
        guard state == .started else {
            log("\(state), aborting")
            return
        }

        animationSettings.completion?()
        state = .finished
        next?.process()
    }

    // MARK: - Chaining promises

    /// Creates a new animation promise with settings, chained to the previous one.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    public func then(_ closureWithSettings: @escaping (inout Settings) -> Closure) -> anim {
        let nextAnim = anim(closureWithoutProcess: closureWithSettings)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a new animation promise, chained to the previous one.
    ///
    /// - Parameter closure: Animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    public func then(_ closure: @escaping Closure) -> anim {
        let nextAnim = anim(closureWithoutProcess: closure)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a new promise for `NSLayoutConstraint` animations with settings, chained to the previous one.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closureWithSettings: Exposes settings values to block, and expects returning animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    public func then(constraintParent: View, _ closureWithSettings: @escaping (inout anim.Settings) -> Closure) -> anim {
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
    public func then(constraintParent: View, _ closure: @escaping Closure) -> anim {
        let nextAnim = anim(constraintParent: constraintParent, closureWithoutProcess: closure)
        chain(to: nextAnim)
        return nextAnim
    }

    /// Creates a promise only waits before running next promise.
    ///
    /// - Parameter milliseconds: Milliseconds to wait.
    /// - Returns: Newly created promise.
    @discardableResult
    public func wait(_ seconds: TimeInterval) -> anim {
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
    public func callback(_ closure: @escaping Closure) -> anim {
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
        next = chainedAnim
        next!.prev = self

        if state == .finished {
            chainedAnim.process()
        }
    }

    /// Stops animation and promise chain.
    public func stop() {
        var currentAnim: anim? = self
        while let a = currentAnim?.next {
            currentAnim = a
        }
        log("\(currentAnim) is at the end of animation chain.")

        while let a = currentAnim, a.state == .created {
            a.state = .cancelled
            currentAnim = a.prev
        }

        log("\(currentAnim) is the animation currently running")

        currentAnim?.state = .cancelled
        currentAnim?.animator?.stopAnimation()
        log("Stopped animation chain")
    }

}

// MARK: - CustomStringConvertible
extension anim: CustomStringConvertible {

    /// String representation
    public var description: String {
        return "anim(\(uid))"
    }

}

// MARK: - Utilities
internal extension anim {

    /// Internal logging function.
    ///
    /// - Parameter message: Message to log.
    /// - Returns: Returns true if logs successfully.
    @discardableResult
    func log(_ message: String) -> Bool {
        guard anim.isLogging else {
            return false
        }

        anim.log("\(description) \(message)")
        return true
    }

    /// Internal loggin on class scope.
    ///
    /// - Parameter message: Message to log.
    /// - Returns: Returns true if logs successfully.
    @discardableResult
    class func log(_ message: String) -> Bool {
        guard anim.isLogging, anim.startupTime != nil else {
            return false
        }

        let since = Date().timeIntervalSince(anim.startupTime!)
        print("\(message) | \(since)")
        return true
    }
}

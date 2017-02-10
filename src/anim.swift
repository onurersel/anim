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

import UIKit

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
        /// Enables user interactions on views while animating.
        public var isUserInteractionsEnabled: Bool = false
    }

    /// Promise state.
    ///
    /// - notBeginned: Animation did not started yet.
    /// - running: Animation is running.
    /// - completed: Animation completed running.
    internal enum State {
        case notBeginned, running, completed
    }

    /// Easing value. Stores two points for cubic easing calculation.
    public struct Ease {

        fileprivate let point1: CGPoint
        fileprivate let point2: CGPoint

        /// Creates a custom easing value for cubic easing calculation.
        ///
        /// - Parameters:
        ///   - point1: First handle point.
        ///   - point2: Second handle point.
        /// - Returns: Easing value.
        public static func custom(point1: CGPoint, point2: CGPoint) -> Ease {
            return Ease(point1: point1, point2: point2)
        }

        /// http://easings.net/#easeInSine
        public static let easeInSine           = Ease(point1: CGPoint(x:0.47, y:0), point2: CGPoint(x:0.745, y:0.715))
        /// http://easings.net/#easeOutSine
        public static let easeOutSine          = Ease(point1: CGPoint(x:0.39, y:0.575), point2: CGPoint(x:0.565, y:1))
        /// http://easings.net/#easeInOutSine
        public static let easeInOutSine        = Ease(point1: CGPoint(x:0.445, y:0.05), point2: CGPoint(x:0.55, y:0.95))

        /// http://easings.net/#easeInQuad
        public static let easeInQuad           = Ease(point1: CGPoint(x:0.55, y:0.085), point2: CGPoint(x:0.68, y:0.53))
        /// http://easings.net/#easeOutQuad
        public static let easeOutQuad          = Ease(point1: CGPoint(x:0.25, y:0.46), point2: CGPoint(x:0.45, y:0.94))
        /// http://easings.net/#easeInOutQuad
        public static let easeInOutQuad        = Ease(point1: CGPoint(x:0.455, y:0.03), point2: CGPoint(x:0.515, y:0.955))

        /// http://easings.net/#easeInCubic
        public static let easeInCubic          = Ease(point1: CGPoint(x:0.55, y:0.055), point2: CGPoint(x:0.675, y:0.19))
        /// http://easings.net/#easeOutCubic
        public static let easeOutCubic         = Ease(point1: CGPoint(x:0.215, y:0.61), point2: CGPoint(x:0.355, y:1))
        /// http://easings.net/#easeInOutCubic
        public static let easeInOutCubic       = Ease(point1: CGPoint(x:0.645, y:0.045), point2: CGPoint(x:0.355, y:1))

        /// http://easings.net/#easeInQuart
        public static let easeInQuart          = Ease(point1: CGPoint(x:0.895, y:0.03), point2: CGPoint(x:0.685, y:0.22))
        /// http://easings.net/#easeOutQuart
        public static let easeOutQuart         = Ease(point1: CGPoint(x:0.165, y:0.84), point2: CGPoint(x:0.44, y:1))
        /// http://easings.net/#easeInOutQuart
        public static let easeInOutQuart       = Ease(point1: CGPoint(x:0.77, y:0), point2: CGPoint(x:0.175, y:1))

        /// http://easings.net/#easeInQuint
        public static let easeInQuint          = Ease(point1: CGPoint(x:0.755, y:0.05), point2: CGPoint(x:0.855, y:0.06))
        /// http://easings.net/#easeOutQuint
        public static let easeOutQuint         = Ease(point1: CGPoint(x:0.23, y:1), point2: CGPoint(x:0.32, y:1))
        /// http://easings.net/#easeInOutQuint
        public static let easeInOutQuint       = Ease(point1: CGPoint(x:0.86, y:0), point2: CGPoint(x:0.07, y:1))

        /// http://easings.net/#easeInExpo
        public static let easeInExpo           = Ease(point1: CGPoint(x:0.95, y:0.05), point2: CGPoint(x:0.795, y:0.035))
        /// http://easings.net/#easeOutExpo
        public static let easeOutExpo          = Ease(point1: CGPoint(x:0.19, y:1), point2: CGPoint(x:0.22, y:1))
        /// http://easings.net/#easeInOutExpo
        public static let easeInOutExpo        = Ease(point1: CGPoint(x:1, y:0), point2: CGPoint(x:0, y:1))

        /// http://easings.net/#easeInCirc
        public static let easeInCirc           = Ease(point1: CGPoint(x:0.6, y:0.04), point2: CGPoint(x:0.98, y:0.335))
        /// http://easings.net/#easeOutCirc
        public static let easeOutCirc          = Ease(point1: CGPoint(x:0.075, y:0.82), point2: CGPoint(x:0.165, y:1))
        /// http://easings.net/#easeInOutCirc
        public static let easeInOutCirc        = Ease(point1: CGPoint(x:0.785, y:0.135), point2: CGPoint(x:0.15, y:0.86))

        /// http://easings.net/#easeInBack
        public static let easeInBack           = Ease(point1: CGPoint(x:0.6, y:-0.28), point2: CGPoint(x:0.735, y:0.045))
        /// http://easings.net/#easeOutBack
        public static let easeOutBack          = Ease(point1: CGPoint(x:0.175, y:0.885), point2: CGPoint(x:0.32, y:1.275))
        /// http://easings.net/#easeInOutBack
        public static let easeInOutBack        = Ease(point1: CGPoint(x:0.68, y:-0.55), point2: CGPoint(x:0.265, y:1.55))

    }

    /// Constraint animation information is stored with this value, instead of a single `Closure`.
    internal struct ConstraintLayout {
        /// Animation block.
        internal var closure: Closure
        /// Top parent of constraints to be animated.
        internal var parent: UIView
    }

    // MARK: - Properties

    /// Default settings for animation. This is being copied to promise for each animation.
    public static var defaultSettings = Settings()
    /// Enables internal logging. This is for debugging.
    internal static var isLogging: Bool = false

    /// Unique promise id.
    fileprivate let uid = UInt32(Date().timeIntervalSince1970)^arc4random_uniform(UInt32.max)
    /// Stored animation block.
    private var animationClosure: Closure?
    /// Animation settings.
    internal var animationSettings: Settings
    /// Reference to next promise chained to this instance.
    internal var next: anim? = nil
    /// State of promise.
    internal var state: State = .notBeginned
    /// Values for constraint animation.
    internal var animationConstraintLayout: ConstraintLayout?
    
    private var animator: UIViewPropertyAnimator?

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

    /// Creates initial animation promise for `NSLayoutConstraint` animations, with settings.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closureWithSettings: Exposes settings values to block, and expects returning animation block.
    @discardableResult
    public convenience init(constraintParent: UIView, _ closureWithSettings: @escaping (inout Settings) -> (Closure)) {
        self.init(constraintParent: constraintParent, closureWithoutProcess: closureWithSettings)
        process()
    }

    /// Creates initial animation promise for `NSLayoutConstraint` animations.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    @discardableResult
    public convenience init(constraintParent: UIView, _ closure: @escaping Closure) {
        self.init(constraintParent: constraintParent, closureWithoutProcess: closure)
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

    /// Creates promise for `NSLayoutConstraint` animations, with settings. To be used while chaining promises.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Exposes settings values to block, and expects returning animation block.
    private convenience init(constraintParent: UIView, closureWithoutProcess closure: @escaping (inout Settings) -> (Closure)) {
        var _settings = anim.defaultSettings
        let _closure = closure(&_settings)
        self.init(settings: _settings, closure:nil)
        self.animationConstraintLayout = ConstraintLayout(closure: _closure, parent: constraintParent)
    }

    /// Creates promise for `NSLayoutConstraint` animations. To be used while chaining promises.
    ///
    /// - Parameters:
    ///   - constraintParent: Top parent where constraints reside.
    ///   - closure: Animation block.
    private convenience init(constraintParent: UIView, closureWithoutProcess closure: @escaping Closure) {
        self.init(settings: anim.defaultSettings, closure:nil)
        self.animationConstraintLayout = ConstraintLayout(closure: closure, parent: constraintParent)
    }

    /// Main initializer.
    ///
    /// - Parameters:
    ///   - settings: Animation settings.
    ///   - closure: Animation closure.
    private init(settings: Settings, closure: Closure?) {
        self.animationSettings = settings
        self.animationClosure = closure

        log("initted")
    }

    // MARK: - Running promises

    /// Start processing animation promise.
    internal func process() {
        log("process")
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
        state = .running

        if let layout = animationConstraintLayout {
            layout.parent.layoutIfNeeded()
            layout.closure()
            animationClosure = layout.parent.layoutIfNeeded
        }

        guard animationSettings.duration > 0 else {
            animationClosure?()
            return completion(pos: .end)
        }

        animator = UIViewPropertyAnimator(duration: animationSettings.duration, controlPoint1: animationSettings.ease.point1, controlPoint2: animationSettings.ease.point2, animations: animationClosure)
        animator!.addCompletion(self.completion)
        animator!.isUserInteractionEnabled = animationSettings.isUserInteractionsEnabled
        animator!.startAnimation()

    }

    /// Animation block completion.
    ///
    /// - Parameter pos: Position of animation. Generated by `UIViewPropertyAnimator`.
    private func completion(pos: UIViewAnimatingPosition) {
        log("completion")
        animationSettings.completion?()
        state = .completed
        next?.delay()
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
    public func then(constraintParent: UIView, _ closureWithSettings: @escaping (inout Settings) -> Closure) -> anim {
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
    public func then(constraintParent: UIView, _ closure: @escaping Closure) -> anim {
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
    private func chain(to chainedAnim: anim) {
        next = chainedAnim

        if state == .completed {
            chainedAnim.delay()
        }
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
    /// - Returns: Returns true if successfully logs
    @discardableResult
    func log(_ message: String) -> Bool {
        guard anim.isLogging else {
            return false
        }

        print("\(description) \(message)")
        return true
    }
}

extension anim.Ease: Equatable {
    /// Checks equality between easing types.
    ///
    /// - Parameters:
    ///   - lhs: First easing value.
    ///   - rhs: Second easing value.
    /// - Returns: Return if two easing values are equal or not.
    public static func == (lhs: anim.Ease, rhs: anim.Ease) -> Bool {
        return lhs.point1 == rhs.point1 && lhs.point2 == rhs.point2
    }
}

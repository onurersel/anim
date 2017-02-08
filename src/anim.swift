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

final public class anim {
    
    
    // MARK: - Types
    
    /// Animation block.
    public typealias Closure = ()->Void
    
    
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
    
    
    /// Cubic easing points.
    public struct Ease {
        
        fileprivate let p1: CGPoint
        fileprivate let p2: CGPoint
        
        public static let easeInSine           = Ease(p1: CGPoint(x:0.47, y:0), p2: CGPoint(x:0.745, y:0.715))
        public static let easeOutSine          = Ease(p1: CGPoint(x:0.39, y:0.575), p2: CGPoint(x:0.565, y:1))
        public static let easeInOutSine        = Ease(p1: CGPoint(x:0.445, y:0.05), p2: CGPoint(x:0.55, y:0.95))
        
        public static let easeInQuad           = Ease(p1: CGPoint(x:0.55, y:0.085), p2: CGPoint(x:0.68, y:0.53))
        public static let easeOutQuad          = Ease(p1: CGPoint(x:0.25, y:0.46), p2: CGPoint(x:0.45, y:0.94))
        public static let easeInOutQuad        = Ease(p1: CGPoint(x:0.455, y:0.03), p2: CGPoint(x:0.515, y:0.955))
        
        public static let easeInCubic          = Ease(p1: CGPoint(x:0.55, y:0.055), p2: CGPoint(x:0.675, y:0.19))
        public static let easeOutCubic         = Ease(p1: CGPoint(x:0.215, y:0.61), p2: CGPoint(x:0.355, y:1))
        public static let easeInOutCubic       = Ease(p1: CGPoint(x:0.645, y:0.045), p2: CGPoint(x:0.355, y:1))
        
        public static let easeInQuart          = Ease(p1: CGPoint(x:0.895, y:0.03), p2: CGPoint(x:0.685, y:0.22))
        public static let easeOutQuart         = Ease(p1: CGPoint(x:0.165, y:0.84), p2: CGPoint(x:0.44, y:1))
        public static let easeInOutQuart       = Ease(p1: CGPoint(x:0.77, y:0), p2: CGPoint(x:0.175, y:1))
        
        public static let easeInQuint          = Ease(p1: CGPoint(x:0.755, y:0.05), p2: CGPoint(x:0.855, y:0.06))
        public static let easeOutQuint         = Ease(p1: CGPoint(x:0.23, y:1), p2: CGPoint(x:0.32, y:1))
        public static let easeInOutQuint       = Ease(p1: CGPoint(x:0.86, y:0), p2: CGPoint(x:0.07, y:1))
        
        public static let easeInExpo           = Ease(p1: CGPoint(x:0.95, y:0.05), p2: CGPoint(x:0.795, y:0.035))
        public static let easeOutExpo          = Ease(p1: CGPoint(x:0.19, y:1), p2: CGPoint(x:0.22, y:1))
        public static let easeInOutExpo        = Ease(p1: CGPoint(x:1, y:0), p2: CGPoint(x:0, y:1))
        
        public static let easeInCirc           = Ease(p1: CGPoint(x:0.6, y:0.04), p2: CGPoint(x:0.98, y:0.335))
        public static let easeOutCirc          = Ease(p1: CGPoint(x:0.075, y:0.82), p2: CGPoint(x:0.165, y:1))
        public static let easeInOutCirc        = Ease(p1: CGPoint(x:0.785, y:0.135), p2: CGPoint(x:0.15, y:0.86))
        
        public static let easeInBack           = Ease(p1: CGPoint(x:0.6, y:-0.28), p2: CGPoint(x:0.735, y:0.045))
        public static let easeOutBack          = Ease(p1: CGPoint(x:0.175, y:0.885), p2: CGPoint(x:0.32, y:1.275))
        public static let easeInOutBack        = Ease(p1: CGPoint(x:0.68, y:-0.55), p2: CGPoint(x:0.265, y:1.55))
        
    }
    
    
    
    // MARK: - Properties
    
    /// Default settings for animation. This is being copied to promise for each animation.
    public static var defaultSettings = Settings()
    /// Enables internal logging. This is for debugging.
    public static var isLogging: Bool = false
    
    /// Unique promise id.
    fileprivate let id = UInt32(Date().timeIntervalSince1970)^arc4random_uniform(UInt32.max)
    /// Stored animation block.
    private let animationClosure: Closure
    /// Animation settings.
    internal var animationSettings: Settings
    /// Reference to next promise chained to this instance.
    internal var next: anim? = nil
    /// State of promise.
    internal var state: State = .notBeginned
    
    
    // MARK: - Initializers
    
    /// Creates initial animation promise, with settings.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    @discardableResult
    public convenience init(_ closure: @escaping (inout Settings)->(Closure)) {
        self.init(closureWithoutProcess:closure)
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
    private convenience init(closureWithoutProcess closure: @escaping (inout Settings)->(Closure)) {
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
    
    
    /// Main initializer.
    ///
    /// - Parameters:
    ///   - settings: Animation settings.
    ///   - closure: Animation closure.
    private init(settings:Settings, closure:@escaping Closure) {
        self.animationSettings = settings
        self.animationClosure = closure
        
        log("initted")
    }
    
    
    // MARK: - Running promises
    
    /// Start processing animation promise.
    private func process() {
        log("process")
        delay()
    }
    
    /// Waits before starting animation block, if delay is setted.
    private func delay() {
        
        log("delay")
        guard animationSettings.delay > 0 else { return self.run() }
        
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
        
        guard animationSettings.duration > 0 else {
            animationClosure()
            return completion(pos: .end)
        }
        
        
        let anim = UIViewPropertyAnimator(duration: animationSettings.duration, controlPoint1: animationSettings.ease.p1, controlPoint2: animationSettings.ease.p2, animations: animationClosure)
        anim.addCompletion(self.completion)
        anim.isUserInteractionEnabled = animationSettings.isUserInteractionsEnabled
        anim.startAnimation()
        
        
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
    
    
    //MARK: - Chaining promises
    
    /// Creates a new animation promise with settings, chained to the previous one.
    ///
    /// - Parameter closure: Exposes settings values to block, and expects returning animation block.
    /// - Returns: Newly created promise.
    @discardableResult
    public func then(_ closure: @escaping (inout Settings)->Closure) -> anim {
        let nextAnim = anim(closureWithoutProcess: closure)
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
    private func chain(to chainedAnim:anim) {
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
        return "anim(\(id))"
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
    public static func ==(lhs: anim.Ease, rhs: anim.Ease) -> Bool {
        return lhs.p1 == rhs.p1 && lhs.p2 == rhs.p2
    }
}

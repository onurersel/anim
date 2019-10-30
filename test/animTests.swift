//
//  animTests.swift
//  animTests
//
//  Created by Onur Ersel on 2017-02-07.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import XCTest
@testable import anim

#if os(iOS) || os(tvOS)
import UIKit
public typealias View = UIView
#elseif os(OSX)
import Cocoa
public typealias View = NSView
#endif

class animTests: XCTestCase {
    
    static var delayMultiplier: Double = 1
    
    override class func setUp() {
        if let multiplier = Bundle.init(for: self).infoDictionary?["delayMultiplier"] as? Double {
            delayMultiplier = multiplier
        }
    }

    override func setUp() {
        anim.defaultSettings = animSettings()
        anim.defaultSettings.duration = 0
    }

    // MARK: - Initializers

    func testInitializers() {

        // with default settings
        XCTAssertNotNil(anim.init({}), "Constructor should not return nil.")

        // with custom settings
        let a = anim.init({ (s) -> (animClosure) in
            return {}
        })
        XCTAssertNotNil(a, "Constructor should not return nil.")

    }

    func testCreateCustomEase() {
        XCTAssertNotNil(animEase.custom(point1: CGPoint(x:0.1, y:0.2), point2: CGPoint(x:0.3, y:0.4)))
    }
    
    func testInitializerForConstraints() {
        let view = View()
        
        // with default settings
        XCTAssertNotNil(anim(constraintParent: view) {}, "Constructor should not return nil.")
        
        // with custom settings
        let a = anim(constraintParent: view) { (s) -> (animClosure) in
            return {}
        }
        XCTAssertNotNil(a, "Constructor should not return nil.")
    }

    // MARK: - Properties

    func testAnimationSpecificCompletion() {
        let e = [
            Event("e1", 0.5*animTests.delayMultiplier),
            Event("e2", 0.8*animTests.delayMultiplier)
        ]

        eventSequence(e) { (log, end) in
            let completion1 = {
                log("e1")
            }
            let completion2 = {
                log("e2")
                end()
            }

            anim({ (settings) -> (animClosure) in
                settings.delay = 0.5*animTests.delayMultiplier
                settings.completion = completion1
                return {}
            }).then({ (settings) -> animClosure in
                settings.delay = 0.3*animTests.delayMultiplier
                settings.completion = completion2
                return {}
            })
        }
    }

    func testDefaultCompletion() {
        let e = [
            Event("e1", 0.6*animTests.delayMultiplier),
            Event("e1", 1.2*animTests.delayMultiplier),
            Event("e1", 1.8*animTests.delayMultiplier)
        ]

        eventSequence(e) { (log, end) in
            let completion = {
                log("e1")
            }

            anim.defaultSettings.delay = 0.6*animTests.delayMultiplier
            anim.defaultSettings.completion = completion

            anim.init({})
                .then {}
                .then {}
                .callback {
                    end()
            }
        }
    }

    func testCopyingGlobalSettings() {
        anim.defaultSettings.delay = 1.537
        anim.defaultSettings.duration = 0.1421
        anim.defaultSettings.ease = .easeInOutBack

        let a = anim.init({})
        let t = a.then {}

        XCTAssertEqual(a.animationSettings.delay, anim.defaultSettings.delay, "Value should be copied from default settings.")
        XCTAssertEqual(a.animationSettings.duration, anim.defaultSettings.duration, "Value should be copied from default settings.")
        XCTAssertEqual(a.animationSettings.ease, anim.defaultSettings.ease, "Value should be copied from default settings.")

        XCTAssertEqual(t.animationSettings.delay, anim.defaultSettings.delay, "Value should be copied from default settings.")
        XCTAssertEqual(t.animationSettings.duration, anim.defaultSettings.duration, "Value should be copied from default settings.")
        XCTAssertEqual(t.animationSettings.ease, anim.defaultSettings.ease, "Value should be copied from default settings.")
    }

    func testOverridingGlobalSettings() {
        anim.defaultSettings.delay = 0.124
        anim.defaultSettings.duration = 0.0014
        anim.defaultSettings.ease = .easeInCirc

        let a = anim.init({ (settings) -> (animClosure) in
            settings.delay = 0.76
            settings.duration = 0.301
            settings.ease = .easeInQuad
            return {}
        })
        let t = a.then { (settings) -> (animClosure) in
            settings.delay = 0.9987
            settings.duration = 0.2743
            settings.ease = .easeInOutCubic
            return {}
        }

        XCTAssertEqual(a.animationSettings.delay, 0.76, "Value should be updated with instance settings.")
        XCTAssertEqual(a.animationSettings.duration, 0.301, "Value should be updated with instance settings.")
        XCTAssertEqual(a.animationSettings.ease, .easeInQuad, "Value should be updated with instance settings.")

        XCTAssertEqual(t.animationSettings.delay, 0.9987, "Value should be updated with instance settings.")
        XCTAssertEqual(t.animationSettings.duration, 0.2743, "Value should be updated with instance settings.")
        XCTAssertEqual(t.animationSettings.ease, .easeInOutCubic, "Value should be updated with instance settings.")
    }

    func testNext() {
        let a = anim.init({})
        let t1 = a.then {}
        let t2 = t1.then {}
        let w = t2.wait(0)
        let c = w.callback {}

        XCTAssertNotNil(a.promise.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(a.promise.next!, t1, "Something wrong with the chaining function.")

        XCTAssertNotNil(t1.promise.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(t1.promise.next!, t2, "Something wrong with the chaining function.")

        XCTAssertNotNil(t2.promise.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(t2.promise.next!, w, "Something wrong with the chaining function.")

        XCTAssertNotNil(w.promise.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(w.promise.next!, c, "Something wrong with the chaining function.")

        XCTAssertNil(c.promise.next, "Instance should not contain reference to next instance.")
    }

    func testState() {

        let e = [Event]()

        eventSequence(e) { (log, end) in

            let a = anim.init({ (settings) -> (animClosure) in
                settings.delay = 0.5*animTests.delayMultiplier
                return {}
            })
            let t = a.then { (settings) -> animClosure in
                settings.delay = 0.5*animTests.delayMultiplier
                return {}
            }

            t.then({ (settings) -> animClosure in
                settings.delay = 0.5*animTests.delayMultiplier
                return {
                    end()
                }
            })

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200*Int(animTests.delayMultiplier)), execute: {
                XCTAssertEqual(a.promise.state, .started, "Something wrong with state cycles.")
                XCTAssertEqual(t.promise.state, .created, "Something wrong with state cycles.")
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(700*Int(animTests.delayMultiplier)), execute: {
                XCTAssertEqual(a.promise.state, .finished, "Something wrong with state cycles.")
                XCTAssertEqual(t.promise.state, .started, "Something wrong with state cycles.")
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1200*Int(animTests.delayMultiplier)), execute: {
                XCTAssertEqual(a.promise.state, .finished, "Something wrong with state cycles.")
                XCTAssertEqual(t.promise.state, .finished, "Something wrong with state cycles.")
            })

        }
    }

    // MARK: - Chaining

    func testChaining() {

        anim.defaultSettings.duration = 0

        let e = [
            Event("e1", 0),
            Event("e2", 0),
            Event("e3", 0)
        ]

        eventSequence(e) { (log, end) in

            anim.init({
                log("e1")
            })
            .then {
                log("e2")
            }
            .then { (settings) -> animClosure in
                return {
                    log("e3")
                    end()
                }
            }

        }

    }

    func testDelayDefaultSettings() {

        anim.defaultSettings.delay = 0.3*animTests.delayMultiplier

        let e = [
            Event("e1", 0.3*animTests.delayMultiplier),
            Event("e2", 0.6*animTests.delayMultiplier),
            Event("e3", 0.9*animTests.delayMultiplier)
        ]

        eventSequence(e) { (log, end) in
            anim.init({
                log("e1")
            })
            .then {
                log("e2")
            }
            .then {
                log("e3")
                end()
            }
        }
    }

    func testDelay() {
        anim.defaultSettings.delay = 0

        let e = [
            Event("e1", 0.8*animTests.delayMultiplier),
            Event("e2", 1.2*animTests.delayMultiplier),
            Event("e3", 1.7*animTests.delayMultiplier)
        ]

        eventSequence(e) { (log, end) in
            anim({ (settings) -> (animClosure) in
                settings.delay = 0.8*animTests.delayMultiplier
                return {
                    log("e1")
                }
            })
            .then({ (settings) -> animClosure in
                settings.delay = 0.4*animTests.delayMultiplier
                return {
                    log("e2")
                }
            })
            .then({ (settings) -> animClosure in
                settings.delay = 0.5*animTests.delayMultiplier
                return {
                    log("e3")
                    end()
                }
            })
        }
    }

    func testCallback() {

        let e = [
            Event("e1", 0.3*animTests.delayMultiplier),
            Event("e2", 0.5*animTests.delayMultiplier)
        ]

        eventSequence(e) { (log, end) in
            anim({ (settings) -> (animClosure) in
                settings.delay = 0.3*animTests.delayMultiplier
                return {}
            })
            .callback {
                log("e1")
            }
            .then({ (settings) -> animClosure in
                settings.delay = 0.2*animTests.delayMultiplier
                return {}
            })
            .callback {
                log("e2")
                end()
            }
        }
    }

    func testWait() {
        anim.defaultSettings.delay = 0

        let e = [
            Event("e1", 0.7*animTests.delayMultiplier),
            Event("e2", 1.1*animTests.delayMultiplier)
        ]

        eventSequence(e) { (log, end) in
            anim.init({})
            .wait(0.7*animTests.delayMultiplier)
            .callback {
                log("e1")
            }
            .wait(0.4*animTests.delayMultiplier)
            .callback {
                log("e2")
                end()
            }
        }
    }
    
    func testChainingForConstraints() {
        anim.defaultSettings.duration = 0
        
        let e = [
            Event("e1", 0),
            Event("e2", 0),
            Event("e3", 1*animTests.delayMultiplier)
        ]
        let view = View()
        
        eventSequence(e) { (log, end) in
            
            anim(constraintParent: view) {
                log("e1")
            }
            .then(constraintParent: view) {
                log("e2")
            }
            .then(constraintParent: view) { (settings) -> animClosure in
                settings.delay = 1*animTests.delayMultiplier
                return {
                    log("e3")
                    end()
                }
            }
            
        }
    }
    
    // MARK: - Stopping
    
    func testStopDelay() {
        let e = [
            Event("e1", 0.7*animTests.delayMultiplier),
            Event("e2", 1.3*animTests.delayMultiplier)
        ]
        
        eventSequence(e) { (log, end) in
            let a = anim({ (settings) -> (animClosure) in
                settings.delay = 0.3*animTests.delayMultiplier
                return {}
            })
            .then({ (settings) -> animClosure in
                settings.delay = 0.4*animTests.delayMultiplier
                return {
                    log("e1")
                }
            })
            .then({ (settings) -> animClosure in
                settings.delay = 0.6*animTests.delayMultiplier
                return {
                    log("e2")
                }
            })
            .then({ (settings) -> animClosure in
                settings.delay = 0.8*animTests.delayMultiplier
                return {
                    XCTFail("Should not be called after animation chain is stopped")
                }
            })
            .then({ (settings) -> animClosure in
                settings.delay = 0.4*animTests.delayMultiplier
                return {
                    XCTFail("Should not be called after animation chain is stopped")
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500*Int(animTests.delayMultiplier)), execute: {
                a.stop()
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2800*Int(animTests.delayMultiplier)), execute: {
                end()
            })
        }
    }
    
    func testStopFromMiddle() {
        let e = [
            Event("e1", 0.4*animTests.delayMultiplier)
        ]
        
        eventSequence(e) { (log, end) in
            
            anim.defaultSettings.delay = 0.4*animTests.delayMultiplier
            let a = anim.init({
                log("e1")
            })
            
            
            a.then {
                log("e2")
            }
            .then {
                XCTFail("Should not be called after animation chain is stopped")
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(600*Int(animTests.delayMultiplier)), execute: {
                a.stop()
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1400*Int(animTests.delayMultiplier)), execute: {
                end()
            })
        }
    }
    
    // MARK: - Animator
    
    func testViewAnimator() {
        runWithAnimator(.viewAnimator)
    }
    
    func testPropertyAnimator() {
        runWithAnimator(.propertyAnimator)
    }
    
    func testMacAnimator() {
        runWithAnimator(.macAnimator)
    }

    // MARK: - Helpers

    // Test callbacks are running in order with correct delays
    typealias EndClosure = () -> Void
    typealias LogClosure = (String) -> Void
    struct Event {
        var key: String
        var delay: TimeInterval
        
        init(_ key: String, _ delay: TimeInterval) {
            self.key = key
            self.delay = delay
        }
    }
    
    func eventSequence(_ events: [Event], _ closure: @escaping ( @escaping LogClosure, @escaping EndClosure) -> Void) {
        let exp = self.expectation(description: "")

        var loggedEvents = [Event]()
        var lastTime = Date().timeIntervalSinceReferenceDate

        let log: LogClosure = { (key) -> Void in
            let now = Date().timeIntervalSinceReferenceDate
            let e = Event(key, now-lastTime)
            lastTime = now
            loggedEvents.append(e)
        }

        let end: EndClosure = {

            XCTAssertEqual(events.count, loggedEvents.count, "Logged event count (\(loggedEvents.count)) should be equal to expected event count (\(events.count))")

            for i in 0..<events.count {
                let expectedEvent = events[i]
                let loggedEvent = loggedEvents[i]

                XCTAssertEqual(expectedEvent.key, loggedEvent.key)

                let expectedDelayDiff: TimeInterval = (i == 0) ? expectedEvent.delay : expectedEvent.delay-events[i-1].delay
                XCTAssertEqual(expectedDelayDiff, loggedEvent.delay, accuracy: 0.28*animTests.delayMultiplier)
            }

            exp.fulfill()
        }

        closure(log, end)
        self.waitForExpectations(timeout: 65, handler: nil)
    }
    
    func runWithAnimator(_ animatorType: AnimatorType) {
        var view = View()
        
        anim.defaultSettings.preferredAnimator = animatorType
        
        #if os(iOS) || os(tvOS)
        anim.defaultSettings.duration = 1
        #elseif os(OSX)
        anim.defaultSettings.duration = 0.1
        #endif
        
        var viewAnimatable: View {
            #if os(iOS) || os(tvOS)
            return view
            #elseif os(OSX)
            return view.animator()
            #endif
        }
        
        let e = [
            Event("e1", 0),
            Event("e2", 0),
            Event("e3", 0)
        ]
        
        eventSequence(e) { (log, end) in
            let a = anim.init({
                viewAnimatable.frame = CGRect(x: 100, y: 0, width: 10, height: 10)
                log("e1")
            })
            
            a.then {
                viewAnimatable.frame = CGRect(x: 0, y: 100, width: 20, height: 20)
                log("e2")
                }
                .then({ (settings) -> animClosure in
                    
                    #if os(iOS) || os(tvOS)
                        settings.isUserInteractionsEnabled = true
                    #endif
                    
                    return {
                        viewAnimatable.frame = CGRect(x: 100, y: 0, width: 10, height: 10)
                        log("e3")
                        a.stop()
                        end()
                    }
                })
        }
    }
}

//
//  animTests.swift
//  animTests
//
//  Created by Onur Ersel on 2017-02-07.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import XCTest
@testable import anim

class animTests: XCTestCase {

    override func setUp() {
        anim.defaultSettings = anim.Settings()
        anim.defaultSettings.duration = 0
    }

    // MARK: - Initializers

    func testInitializers() {

        // with default settings
        XCTAssertNotNil(anim {}, "Constructor should not return nil.")

        // with custom settings
        let a = anim { (s) -> (anim.Closure) in
            return {}
        }
        XCTAssertNotNil(a, "Constructor should not return nil.")

    }

    func testCreateCustomEase() {
        XCTAssertNotNil(anim.Ease.custom(point1: CGPoint(x:0.1, y:0.2), point2: CGPoint(x:0.3, y:0.4)))
    }
    
    func testInitializerForConstraints() {
        let view = UIView()
        
        // with default settings
        XCTAssertNotNil(anim(constraintParent: view) {}, "Constructor should not return nil.")
        
        // with custom settings
        let a = anim(constraintParent: view) { (s) -> (anim.Closure) in
            return {}
        }
        XCTAssertNotNil(a, "Constructor should not return nil.")
    }

    // MARK: - Properties

    func testAnimationSpecificCompletion() {
        let e = [
            Event("e1", 0.5),
            Event("e2", 0.8)
        ]

        eventSequence(e) { (log, end) in
            let completion1 = {
                log("e1")
            }
            let completion2 = {
                log("e2")
                end()
            }

            anim({ (settings) -> (anim.Closure) in
                settings.delay = 0.5
                settings.completion = completion1
                return {}
            }).then({ (settings) -> anim.Closure in
                settings.delay = 0.3
                settings.completion = completion2
                return {}
            })
        }
    }

    func testDefaultCompletion() {
        let e = [
            Event("e1", 0.6),
            Event("e1", 1.2),
            Event("e1", 1.8)
        ]

        eventSequence(e) { (log, end) in
            let completion = {
                log("e1")
            }

            anim.defaultSettings.delay = 0.6
            anim.defaultSettings.completion = completion

            anim {}
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

        let a = anim {}
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

        let a = anim { (settings) -> (anim.Closure) in
            settings.delay = 0.76
            settings.duration = 0.301
            settings.ease = .easeInQuad
            return {}
        }
        let t = a.then { (settings) -> (anim.Closure) in
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
        let a = anim {}
        let t1 = a.then {}
        let t2 = t1.then {}
        let w = t2.wait(0)
        let c = w.callback {}

        XCTAssertNotNil(a.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(a.next!.description, t1.description, "Something wrong with the chaining function.")

        XCTAssertNotNil(t1.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(t1.next!.description, t2.description, "Something wrong with the chaining function.")

        XCTAssertNotNil(t2.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(t2.next!.description, w.description, "Something wrong with the chaining function.")

        XCTAssertNotNil(w.next, "Instance should contain reference to next instance.")
        XCTAssertEqual(w.next!.description, c.description, "Something wrong with the chaining function.")

        XCTAssertNil(c.next, "Instance should not contain reference to next instance.")
    }

    func testState() {

        let e = [Event]()

        eventSequence(e) { (log, end) in

            let a = anim { (settings) -> (anim.Closure) in
                settings.delay = 0.5
                return {}
            }
            let t = a.then { (settings) -> anim.Closure in
                settings.delay = 0.5
                return {}
            }

            t.then({ (settings) -> anim.Closure in
                settings.delay = 0.5
                return {
                    end()
                }
            })

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200), execute: { 
                XCTAssertEqual(a.state, .started, "Something wrong with state cycles.")
                XCTAssertEqual(t.state, .created, "Something wrong with state cycles.")
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(700), execute: {
                XCTAssertEqual(a.state, .finished, "Something wrong with state cycles.")
                XCTAssertEqual(t.state, .started, "Something wrong with state cycles.")
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1200), execute: {
                XCTAssertEqual(a.state, .finished, "Something wrong with state cycles.")
                XCTAssertEqual(t.state, .finished, "Something wrong with state cycles.")
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

            anim {
                log("e1")
            }
            .then {
                log("e2")
            }
            .then { (settings) -> anim.Closure in
                return {
                    log("e3")
                    end()
                }
            }

        }

    }

    func testDelayDefaultSettings() {

        anim.defaultSettings.delay = 0.3

        let e = [
            Event("e1", 0.3),
            Event("e2", 0.6),
            Event("e3", 0.9)
        ]

        eventSequence(e) { (log, end) in
            anim {
                log("e1")
            }
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
            Event("e1", 0.8),
            Event("e2", 1.2),
            Event("e3", 1.7)
        ]

        eventSequence(e) { (log, end) in
            anim({ (settings) -> (anim.Closure) in
                settings.delay = 0.8
                return {
                    log("e1")
                }
            })
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.4
                return {
                    log("e2")
                }
            })
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.5
                return {
                    log("e3")
                    end()
                }
            })
        }
    }

    func testCallback() {

        let e = [
            Event("e1", 0.3),
            Event("e2", 0.5)
        ]

        eventSequence(e) { (log, end) in
            anim({ (settings) -> (anim.Closure) in
                settings.delay = 0.3
                return {}
            })
            .callback {
                log("e1")
            }
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.2
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
            Event("e1", 0.7),
            Event("e2", 1.1)
        ]

        eventSequence(e) { (log, end) in
            anim {}
            .wait(0.7)
            .callback {
                log("e1")
            }
            .wait(0.4)
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
            Event("e3", 1)
        ]
        let view = UIView()
        
        eventSequence(e) { (log, end) in
            
            anim(constraintParent: view) {
                log("e1")
            }
            .then(constraintParent: view) {
                log("e2")
            }
            .then(constraintParent: view) { (settings) -> anim.Closure in
                settings.delay = 1
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
            Event("e1", 0.7),
            Event("e2", 1.3)
        ]
        
        eventSequence(e) { (log, end) in
            let a = anim({ (settings) -> (anim.Closure) in
                settings.delay = 0.3
                return {}
            })
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.4
                return {
                    log("e1")
                }
            })
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.6
                return {
                    log("e2")
                }
            })
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.8
                return {
                    XCTFail("Should not be called after animation chain is stopped")
                }
            })
            .then({ (settings) -> anim.Closure in
                settings.delay = 0.4
                return {
                    XCTFail("Should not be called after animation chain is stopped")
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1500), execute: {
                a.stop()
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(2800), execute: {
                end()
            })
        }
    }
    
    func testStopFromMiddle() {
        let e = [
            Event("e1", 0.4)
        ]
        
        eventSequence(e) { (log, end) in
            
            anim.defaultSettings.delay = 0.4
            let a = anim {
                log("e1")
            }
            
            
            a.then {
                log("e2")
            }
            .then {
                XCTFail("Should not be called after animation chain is stopped")
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(600), execute: {
                a.stop()
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1400), execute: {
                end()
            })
        }
    }
    
    // MARK: - Animators
    
    func testViewAnimator() {
        runWithAnimator(.viewAnimator)
    }
    
    func testPropertyAnimator() {
        runWithAnimator(.propertyAnimator)
    }
    
    private func runWithAnimator(_ animator: anim.AnimatorType) {
        anim.defaultSettings.preferredAnimator = animator
        anim.defaultSettings.duration = 1
        
        let view = UIView()
        let e = [
            Event("e1", 0),
            Event("e2", 0),
            Event("e3", 0)
        ]
        
        eventSequence(e) { (log, end) in
            let a = anim {
                view.frame.origin.x = 100
                log("e1")
            }
            
            a.then {
                view.frame.origin.x = 0
                log("e2")
            }
            .then({ (settings) -> anim.Closure in
                settings.isUserInteractionsEnabled = true
                return {
                    view.frame.origin.x = 35
                    log("e3")
                    a.stop()
                    end()
                }
            })
        }
    }
    
    // MARK: - Logging

    func testLog() {
        let a = anim {}

        anim.isLogging = false
        let result1 = a.log("test")
        XCTAssertFalse(result1, "Should not be logging while it's disabled.")

        anim.isLogging = true
        let result2 = a.log("test")
        XCTAssertTrue(result2, "Should be logging while it's not disabled.")

        anim.isLogging = false
    }
    
    func testClassLog() {
        anim.isLogging = false
        let result1 = anim.log("test")
        XCTAssertFalse(result1, "Should not be logging while it's disabled.")
        
        anim.isLogging = true
        let result2 = anim.log("test")
        XCTAssertTrue(result2, "Should be logging while it's not disabled.")
        
        anim.isLogging = false
    }

    // MARK: - Helpers

    // Test callbacks are running in order with correct delays
    typealias EndClosure = () -> Void
    typealias LogClosure = (String) -> Void
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
                XCTAssertEqualWithAccuracy(expectedDelayDiff, loggedEvent.delay, accuracy: 0.28)
            }

            exp.fulfill()
        }

        closure(log, end)
        self.waitForExpectations(timeout: 5, handler: nil)
    }

    struct Event {
        var key: String
        var delay: TimeInterval

        init(_ key: String, _ delay: TimeInterval) {
            self.key = key
            self.delay = delay
        }
    }
}

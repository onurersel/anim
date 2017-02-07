//
//  animTests.swift
//  animTests
//
//  Created by Onur Ersel on 2017-02-07.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import XCTest

class animTests: XCTestCase {
    
    func testInitializers() {
        
        // with default settings
        XCTAssertNotNil(anim {}, "Constructor should not return nil.")
        
        
        // with custom settings
        let a = anim { (s) -> (anim.Closure) in
            return {}
        }
        XCTAssertNotNil(a, "Constructor should not return nil.")
        
    }
    
    func testInitializerWithSettings() {
        
        anim.defaultSettings.delay = 0
        
        let e = [
            Event("e1", 0),
            Event("e2", 0)
        ]
        
        eventSequence(e) { (log, end) in
            anim({ (settings) -> (anim.Closure) in
                return {
                    log("e1")
                }
            })
            .then {
                log("e2")
                end()
            }
        }
        
    }
    
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
            Event("e1", 0.1),
            Event("e2", 0.5),
            Event("e3", 0.7)
        ]
        
        eventSequence(e) { (log, end) in
            anim({ (settings) -> (anim.Closure) in
                settings.delay = 0.1
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
                settings.delay = 0.2
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
    
    
    
    // helper
    // test callbacks are running in order with correct delays
    typealias EndClosure = ()->Void
    typealias LogClosure = (String)->Void
    func eventSequence(_ events: [Event], _ closure: @escaping ( @escaping LogClosure, @escaping EndClosure)->Void) {
        let exp = self.expectation(description: "")
        
        var loggedEvents = [Event]()
        var lastTime = Date().timeIntervalSinceReferenceDate
        
        let log: LogClosure = { (key)->Void in
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
                XCTAssertEqualWithAccuracy(expectedDelayDiff, loggedEvent.delay, accuracy: 0.1)
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

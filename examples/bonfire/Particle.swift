//
//  Particle.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

class Particle: UIView {
    
    var scaleContainer: UIView!
    var rotationContainer: UIView!
    var emitter: Emitter!
    
    class func new(withEmitter emitter: Emitter) -> Particle {
        let particle = Particle()
        particle.emitter = emitter
        
        particle.scaleContainer = UIView()
        particle.addSubview(particle.scaleContainer)
        
        particle.rotationContainer = UIImageView(image:emitter.settings.image)
        particle.rotationContainer.contentMode = .center
        particle.scaleContainer.addSubview(particle.rotationContainer)
        
        return particle
    }
    
    func reset() {
        // reset transform and alpha
        let randomizedInitialScale = emitter.settings.scale.randomize(range: 0.13)
        scaleContainer.transform = CGAffineTransform.identity.scaledBy(x: randomizedInitialScale, y: randomizedInitialScale)
        rotationContainer.transform = CGAffineTransform.identity
        self.frame = CGRect(x: 0, y: 0, width: 2, height: 2)
        self.alpha = emitter.settings.initialAlpha
        rotationContainer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        scaleContainer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        
        // position
        let size = emitter.settings.emitSize
        let x = -size.width / 2.0 + size.width * DoubleRange.random01.cgFloat
        let y = -size.height / 2.0 + size.height * DoubleRange.random01.cgFloat
        self.frame.origin = CGPoint(x: x, y: y)
    }
    
    func move() {
        let startX = self.frame.origin.x
        let startY = self.frame.origin.y
        let randomMultiplier: CGFloat = (DoubleRange.random01 < 0.5) ? -1 : 1
        let steps: [CGFloat] = [ emitter.settings.wobble.random.cgFloat * randomMultiplier,
                                 emitter.settings.wobble.random.cgFloat * -randomMultiplier,
                                 emitter.settings.wobble.random.cgFloat * randomMultiplier]
        
        // move up
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutQuad
            settings.duration = self.emitter.settings.duration
            return {
                self.frame.origin.y = startY - self.emitter.settings.ascend.random.cgFloat
            }
        }
        .callback {
            self.emitter.recycle(particle: self)
        }
        
        // fade
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutQuint
            settings.duration = self.emitter.settings.duration * 0.2
            return {
                self.alpha = 1
            }
            }
            .then { (settings) -> animClosure in
                settings.ease = .easeOutQuint
                settings.duration = self.emitter.settings.duration * 0.8
                return {
                    self.alpha = 0
                }
        }
        
        // move sideways
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInOutQuad
            settings.duration = self.emitter.settings.duration * 0.2
            return {
                self.frame.origin.x = startX + steps[0]
            }
            }
            .then { (settings) -> animClosure in
                settings.ease = .easeInOutQuad
                settings.duration = self.emitter.settings.duration * 0.4
                return {
                    self.frame.origin.x = startX * 0.5 + steps[1] * (self.emitter.settings.pullToCenter ? 0.5 : 1)
                }
            }
            .then { (settings) -> animClosure in
                settings.ease = .easeInOutQuad
                settings.duration = self.emitter.settings.duration * 0.4
                return {
                    self.frame.origin.x = steps[2] * (self.emitter.settings.pullToCenter ? 0 : 1)
                }
        }
        
        // scale
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInOutSine
            settings.duration = self.emitter.settings.duration
            return {
                self.scaleContainer.transform = CGAffineTransform.identity.scaledBy(x: self.emitter.settings.scale * 0.3, y: self.emitter.settings.scale * 0.3)
            }
        }
 
        // rotate
        if emitter.settings.rotate {
            anim { (settings) -> (animClosure) in
                settings.ease = .easeOutExpo
                settings.duration = self.emitter.settings.duration * 0.2
                return {
                    self.rotationContainer.transform = CGAffineTransform.identity.rotated(by: steps[0].radian)
                }
            }
            .then { (settings) -> animClosure in
                settings.ease = .easeOutExpo
                settings.duration = self.emitter.settings.duration * 0.4
                return {
                    self.rotationContainer.transform = CGAffineTransform.identity.rotated(by: steps[1].radian)
                }
            }
            .then { (settings) -> animClosure in
                settings.ease = .easeOutExpo
                settings.duration = self.emitter.settings.duration * 0.4
                return {
                    self.rotationContainer.transform = CGAffineTransform.identity.rotated(by: steps[2].radian)
                }
            }
        }
        
    }
    
}

//
//  Particle.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

class Particle: UIView {
    
    static var allParticles = [Particle]()
    static var availableparticles = [Particle]()
    
    var rotationContainer: UIView!
    
    class func create() -> Particle {
        
        let particle: Particle = (availableparticles.popLast() ?? newParticle())
        particle.reset()
        
        return particle
    }
    
    private class func newParticle() -> Particle {
        let particle = Particle()
        
        particle.rotationContainer = UIView()
        particle.rotationContainer.backgroundColor = UIColor.white
        particle.addSubview(particle.rotationContainer)
        
        allParticles.append(particle)
        return particle
    }
    
    private func reset() {
        rotationContainer.transform = CGAffineTransform.identity
        self.frame = CGRect(x: 0, y: 0, width: 2, height: 5)
        self.alpha = 0.1
        rotationContainer.frame = CGRect(x: 0,
                                         y: 0,
                                         width: self.frame.size.width,
                                         height: self.frame.size.height)
    }
    
    func move() {
        let startX = self.frame.origin.x
        let startY = self.frame.origin.y
        let randomMultiplier: CGFloat = (CGFloat.random < 0.5) ? -1 : 1
        let steps: [CGFloat] = [ CGFloat.random(offset: 5 * randomMultiplier, range: 40),
                                 CGFloat.random(offset: 5 * -randomMultiplier, range: 40),
                                 CGFloat.random(offset: 5 * randomMultiplier, range: 40)]
        
        anim.defaultSettings.delay = 0
        anim.defaultSettings.duration = 2
        
        // move up
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutQuad
            return {
                self.frame.origin.y = startY - CGFloat.random(from: 80, to: 160)
            }
        }
        
        // fade
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInSine
            settings.duration = anim.defaultSettings.duration * 0.1
            return {
                self.alpha = 1
            }
        }
        .then { (settings) -> animClosure in
            settings.ease = .easeOutQuint
            settings.duration = anim.defaultSettings.duration * 0.9
            return {
                self.alpha = 0
            }
        }
        
        // move sideways
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInOutQuad
            settings.duration = anim.defaultSettings.duration * 0.2
            return {
                self.frame.origin.x = startX + steps[0]
            }
        }
        .then { (settings) -> animClosure in
            settings.ease = .easeInOutQuad
            settings.duration = anim.defaultSettings.duration * 0.4
            return {
                self.frame.origin.x = startX + steps[1]
            }
        }
        .then { (settings) -> animClosure in
            settings.ease = .easeInOutQuad
            settings.duration = anim.defaultSettings.duration * 0.4
            return {
                self.frame.origin.x = startX + steps[2]
            }
        }
        
        
        
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutExpo
            settings.duration = anim.defaultSettings.duration * 0.2
            return {
                self.rotationContainer.transform = CGAffineTransform.identity.rotated(by: steps[0].radian)
            }
        }
        .then { (settings) -> animClosure in
            settings.ease = .easeOutExpo
            settings.duration = anim.defaultSettings.duration * 0.4
            return {
                self.rotationContainer.transform = CGAffineTransform.identity.rotated(by: steps[1].radian)
            }
        }
        .then { (settings) -> animClosure in
            settings.ease = .easeOutExpo
            settings.duration = anim.defaultSettings.duration * 0.4
            return {
                self.rotationContainer.transform = CGAffineTransform.identity.rotated(by: steps[2].radian)
            }
        }
        .callback {
            self.removeFromSuperview()
            Particle.availableparticles.append(self)
        }
    }
    
}

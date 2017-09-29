//
//  Emitter.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

class Emitter: UIView {
    
    struct Settings {
        var image: UIImage
        var emitSize: CGSize
        var pullToCenter: Bool
        var frequency: DoubleRange
        var ascend: DoubleRange
        var wobble: DoubleRange
        var rotate: Bool
        var scale: CGFloat
        var duration: TimeInterval
        var initialAlpha: CGFloat

        mutating func applyPlatformMultiplier() {
            emitSize = emitSize.platform
            ascend = ascend.platform
        }
    }
    
    var settings: Settings! {
        didSet {
            settings.applyPlatformMultiplier()
        }
    }
    private var availableParticles = [Particle]()
    
    
    func start(_ settings: Settings) {
        self.settings = settings
        self.clipsToBounds = false
        
        fire()
    }
    
    func fire() {
        addParticle()
        
        let delay = Int(settings.frequency.random * 1000)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay), execute: fire)
    }
    
    func addParticle() {
        let particle = self.dequeueParticle()
        addSubview(particle)
        particle.move()
    }
    
    func dequeueParticle() -> Particle {
        let particle: Particle = (availableParticles.popLast() ?? Particle.new(withEmitter:self))
        particle.reset()
        
        return particle
    }
    
    func recycle(particle: Particle) {
        particle.removeFromSuperview()
        availableParticles.append(particle)
    }
}

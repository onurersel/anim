//
//  Emitter.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

class Emitter: UIView {
    
    let emitterSize = CGSize(width: 120, height: 20)
    
    func start() {
        self.clipsToBounds = false
        self.backgroundColor = UIColor.red
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { (timer) in
            let particle = Particle.create()
            self.addSubview(particle)
            self.position(particle: particle)
            particle.move()
        }
    }
    
    private func position(particle: Particle) {
        let x = -emitterSize.width/2.0 + emitterSize.width*CGFloat.random
        let y = -emitterSize.height/2.0 + emitterSize.height*CGFloat.random
        particle.frame.origin = CGPoint(x: x, y: y)
    }
    
}

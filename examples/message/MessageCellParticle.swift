//
//  MessageCellParticle.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-20.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

extension DialogueBubbleTableCell {
    
    class Particle: UIView {
        
        class func create() -> Particle {
            let view = Particle()
            
            view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            view.layer.cornerRadius = 15
            
            return view
        }
        
        
        func fire(from: CGPoint, to: CGPoint, color: UIColor, completion: @escaping (Particle)->Void) {
            self.center = from
            self.backgroundColor = color
            self.transform = CGAffineTransform.identity
            self.alpha = 1
            
            anim { (settings) -> (animClosure) in
                settings.ease = .easeInSine
                settings.duration = 0.6
                return {
                    self.alpha = 0
                }
            }
            
            anim { (settings) -> (animClosure) in
                settings.duration = 0.7
                return {
                    self.center = to
                    self.transform = CGAffineTransform.identity.scaledBy(x: 0.2, y: 0.2)
                }
            }
            .callback {
                completion(self)
            }
        }
        
    }
    
    class Emitter {
        
        private var availableParticles = [Particle]()
        
        private func getParticle() -> Particle {
            return availableParticles.popLast() ?? Particle.create()
        }
        
        func fire(view: UIView, position: CGPoint, bubbleSize: CGSize, color: UIColor) {
            
            let offset: CGFloat = 22
            
            for _ in 0...10 {
                let particle = self.getParticle()
                var bubbleRect = CGRect(x: -bubbleSize.width/2.0, y: -bubbleSize.height/2.0, width: bubbleSize.width, height: bubbleSize.height)
                bubbleRect = UIEdgeInsetsInsetRect(bubbleRect, UIEdgeInsetsMake(-offset, -offset, -offset, -offset))
                let randomPoint = bubbleRect.randomPointOnRect
                
                view.addSubview(particle)
                particle.fire(from: position, to: randomPoint, color: color, completion: self.recycleParticle)
            }
            
        }
        
        private func recycleParticle(particle: Particle) {
            particle.removeFromSuperview()
            availableParticles.append(particle)
        }
        
    }
    
}

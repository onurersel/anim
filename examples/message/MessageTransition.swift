//
//  MessageTransition.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

protocol AnimatedViewController {
    var estimatedInAnimationDuration: TimeInterval {get}
    var estimatedOutAnimationDuration: TimeInterval {get}
    
    func animateIn(_ completion: @escaping ()->Void)
    func animateOut(_ completion: @escaping ()->Void)
    func prepareForAnimateIn()
    func prepareForAnimateOut()
    
}

class DefaultAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let outAnimated = transitionContext!.viewController(forKey: .from) as! AnimatedViewController
        let inAnimated = transitionContext!.viewController(forKey: .to) as! AnimatedViewController
        return outAnimated.estimatedOutAnimationDuration + inAnimated.estimatedInAnimationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let outViewController = transitionContext.viewController(forKey: .from)!
        let inViewController = transitionContext.viewController(forKey: .to)!
        let outAnimated = outViewController as! AnimatedViewController
        let inAnimated = inViewController as! AnimatedViewController
        
        let container = transitionContext.containerView
        
        outAnimated.prepareForAnimateOut()
        inAnimated.prepareForAnimateIn()
        
        outAnimated.animateOut {
            container.addSubview(inViewController.view)
            inAnimated.animateIn {
                transitionContext.completeTransition(true)
            }
        }
    }
}

class MessageConversationShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let listViewController = transitionContext.viewController(forKey: .from) as! MessageListViewController
        let dialogueViewController = transitionContext.viewController(forKey: .to) as! MessageDialogueViewController
        
        let container = transitionContext.containerView
        
        listViewController.prepareForAnimateOut()
        dialogueViewController.prepareForAnimateIn()
        
        listViewController.animateOut {}
        
        
        
        guard let bubbleFrame = listViewController.bubbleTransitionFrame else {
            return
        }
        
        let rippleView = RippleView.create(color: dialogueViewController.userColor, radius: bubbleFrame.size.width * 0.5)
        container.addSubview(rippleView)
        
        rippleView.animateIn(at: bubbleFrame)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(200)) {
            container.insertSubview(dialogueViewController.view, belowSubview: rippleView)
            
            dialogueViewController.animateIn {
                rippleView.removeFromSuperview()
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(400)) {
                transitionContext.completeTransition(true)
            }
        }
        
    }
    
}


class RippleView: UIView {
    
    private var colorCircleView: UIView!
    private var grayCircleView: UIView!
    
    class func create(color: UIColor, radius: CGFloat) -> RippleView {
        let view = RippleView()
        
        view.colorCircleView = RippleView.createCircleView(withColor: color, radius: radius)
        view.addSubview(view.colorCircleView)
        
        view.grayCircleView = RippleView.createCircleView(withColor: Color.midGray, radius: radius)
        view.colorCircleView.addSubview(view.grayCircleView)
        
        return view
    }
    
    private class func createCircleView(withColor color: UIColor, radius: CGFloat) -> UIView {
        let view = UIView()
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x:radius, y:radius), radius: radius, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = color.cgColor
        shapeLayer.strokeColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 0
        
        view.layer.addSublayer(shapeLayer)
        
        return view
    }
    
    func animateIn(at frame: CGRect) {
        let scale = (UIScreen.main.bounds.height / frame.size.height) * 2
        let frameCenter = frame.center
        let screenFrame = UIScreen.main.bounds
        self.center = frameCenter
        colorCircleView.frame = frame
        colorCircleView.center = CGPoint.zero
        
        anim { (settings) -> (animClosure) in
            settings.duration = 1.4
            settings.delay = 0.3
            settings.ease = .easeOutExpo
            return {
                self.center = CGPoint(x: screenFrame.center.x, y: -screenFrame.size.height)
            }
        }
        

        anim { (settings) -> (animClosure) in
            settings.duration = 0.3
            settings.ease = .easeInQuint
            return {
                self.colorCircleView.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            }
        }
        .then { (settings) -> animClosure in
            settings.duration = 1.4
            settings.ease = .easeOutExpo
            return {
                self.colorCircleView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
        }
        
        anim { (settings) -> (animClosure) in
            settings.duration = 0.2
            settings.ease = .easeInQuint
            return {
                self.grayCircleView.alpha = 0
            }
        }
    }
    
}

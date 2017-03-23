//
//  BackButton.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


// MARK: - Back Bar Button Item

class BackBarButtonItem: UIBarButtonItem {
    
    weak var buttonView: BackButton?
    
    class func create() -> BackBarButtonItem {
        let view = BackButton.create()
        view.size(width: 38, height: 38)
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 19
        
        let barButton = BackBarButtonItem(customView: view)
        barButton.buttonView = view
        
        return barButton
    }
}


// MARK: - Back Button

class BackButton: UIButton, LeftNavigationBarButton {
    
    private var arrowImageView: UIImageView!
    private var arrowCenterXConstraint: NSLayoutConstraint!
    
    
    class func create() -> BackButton {
        let view = BackButton()
        
        // background
        view.backgroundColor = Color.lightGray
        
        // arrow
        view.arrowImageView = UIImageView(image: #imageLiteral(resourceName: "back_arrow"))
        view.addSubview(view.arrowImageView)
        view.arrowCenterXConstraint = UIView.align(view: view.arrowImageView, to: view, attribute: .centerX)
        UIView.align(view: view.arrowImageView, to: view, attribute: .centerY)
        
        view.addTarget(view, action: #selector(view.downAction), for: .touchDown)
        view.addTarget(view, action: #selector(view.upAction), for: .touchUpInside)
        view.addTarget(view, action: #selector(view.upAction), for: .touchCancel)
        view.addTarget(view, action: #selector(view.upAction), for: .touchUpOutside)
        
        return view
    }
    
    
    // MARK: Animations
    
    func animateArrowIn() {
        arrowImageView.alpha = 0
        anim { (settings) -> (animClosure) in
            settings.delay = 0.5
            settings.duration = 0.5
            return {
                self.arrowImageView.alpha = 1
            }
        }
        
        arrowCenterXConstraint.constant = 8
        anim(constraintParent: self) { (settings) -> animClosure in
            settings.ease = .easeOutQuint
            settings.delay = 0.5
            settings.duration = 0.7
            return {
                self.arrowCenterXConstraint.constant = 0
            }
        }
    }
    
    func animateArrowOut() {
        anim { (settings) -> (animClosure) in
            settings.duration = 0.7
            settings.ease = .easeInSine
            return {
                self.arrowImageView.alpha = 0
            }
        }
    }
    
    
    // MARK: Actions / Handlers
    
    @objc
    func downAction() {
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutBack
            settings.duration = 0.1
            return {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1.4, y: 1.4)
            }
        }
    }
    
    @objc
    func upAction() {
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutBack
            settings.duration = 0.16
            return {
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    deinit {
        removeTarget(self, action: #selector(self.downAction), for: .touchDown)
        removeTarget(self, action: #selector(self.upAction), for: .touchUpInside)
        removeTarget(self, action: #selector(self.upAction), for: .touchCancel)
        removeTarget(self, action: #selector(self.upAction), for: .touchUpOutside)
    }
}

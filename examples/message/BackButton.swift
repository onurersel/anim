//
//  BackButton.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

class BackBarButtonItem: UIBarButtonItem {
    class func create() -> BackBarButtonItem {
        let view = BackButton.create()
        view.size(width: 38, height: 38)
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 19
        
        let barButton = BackBarButtonItem(customView: view)
        
        return barButton
    }
}

class BackButton: UIButton, LeftNavigationBarButton {
    
    private var arrowImageView: UIImageView!
    private var centerXConstraint: NSLayoutConstraint!
    
    class func create() -> BackButton {
        let view = BackButton()
        
        // background
        view.backgroundColor = Color.lightGray
        
        // arrow
        view.arrowImageView = UIImageView(image: #imageLiteral(resourceName: "back_arrow"))
        view.addSubview(view.arrowImageView)
        view.centerXConstraint = UIView.align(view: view.arrowImageView, to: view, attribute: .centerX)
        UIView.align(view: view.arrowImageView, to: view, attribute: .centerY)
        
        return view
    }
    
    func animateArrowIn() {
        arrowImageView.alpha = 0
        anim { (settings) -> (animClosure) in
            settings.delay = 0.5
            settings.duration = 0.5
            return {
                self.arrowImageView.alpha = 1
            }
        }
        
        centerXConstraint.constant = 8
        anim(constraintParent: self) { (settings) -> animClosure in
            settings.ease = .easeOutQuint
            settings.delay = 0.5
            settings.duration = 0.7
            return {
                self.centerXConstraint.constant = 0
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
}

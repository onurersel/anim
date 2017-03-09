//
//  ProfileTransition.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-09.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit


class ProfileDetailShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        NavigationBarController.shared.hide()
        
        let detailViewController = transitionContext.viewController(forKey: .to) as! ProfileDetailViewController
        transitionContext.containerView.addSubview(detailViewController.view)
        detailViewController.startHeaderInAnimation()
        transitionContext.completeTransition(true)
    }
    
}

//
//  ProfileTransition.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-09.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit


class ProfileDetailShowAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let profileViewController = transitionContext.viewController(forKey: .from) as! ProfileViewController
        let detailViewController = transitionContext.viewController(forKey: .to) as! ProfileDetailViewController

        transitionContext.containerView.addSubview(detailViewController.view)

        detailViewController.prepareForDetailBodyIn()
        profileViewController.animateOut {}

        if let profilePicture = profileViewController.selectedProfileCell?.profilePictureView,
            let position = profileViewController.profilePicturePositionInViewController() {

            detailViewController.position(profilePicture: profilePicture, position: position)
            detailViewController.startHeaderInAnimation()
            detailViewController.animateProfileDetailBodyIn {}
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1800)) {
                transitionContext.completeTransition(true)
            }
        }

    }
}


class ProfileDetailHideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        let detailViewController = transitionContext.viewController(forKey: .from) as! ProfileDetailViewController
        let profileViewController = transitionContext.viewController(forKey: .to) as! ProfileViewController

        transitionContext.containerView.insertSubview(profileViewController.view, at: 0)

        if let selectedCell = profileViewController.selectedProfileCell {
            detailViewController.positionBack {
                profileViewController.positionProfilePictureIn(profileCell: selectedCell)
                transitionContext.completeTransition(true)
            }
        }

        detailViewController.animateProfileDetailBodyOut()
        NavigationBarController.shared.update(color: Color.lightGray)
        detailViewController.animateHeaderOut {
            NavigationBarController.shared.showProfile()
        }
        
        profileViewController.restoreCells()
    }
}

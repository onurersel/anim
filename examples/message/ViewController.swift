//
//  ViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-28.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


class ViewController: UINavigationController, UINavigationControllerDelegate {
    
    // retaining circle menu
    private var circleMenuController: CircleMenuController!
    
    override func viewDidLoad() {
        anim.defaultSettings.isUserInteractionsEnabled = true
        
        // navigation bar
        NavigationBarController.configure(navigationBar: self.navigationBar)
        self.delegate = self
        
        // circle menu
        circleMenuController = CircleMenuController(parent: self.view)
        
        // initial view controller
        self.pushViewController(ProfileViewController(), animated: false)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC is ProfileViewController && toVC is ProfileDetailViewController && operation == .push {
            return ProfileDetailShowAnimator()
        } else if fromVC is ProfileDetailViewController && toVC is ProfileViewController && operation == .pop {
            return ProfileDetailHideAnimator()
        }
        
        return nil
    }
}

class NavigationBarController {
    static let shared = NavigationBarController()
    private static var navigationBar: UINavigationBar!
    
    fileprivate let heightDefault: CGFloat = 71
    fileprivate var height: CGFloat = 71
    
    private var navigationBar: UINavigationBar {
        return NavigationBarController.navigationBar
    }
    
    class func configure(navigationBar: UINavigationBar) {
        self.navigationBar = navigationBar
        shared.configureForProfile()
    }
    
    func configureForProfile() {
        height = heightDefault
        navigationBar.backgroundColor = Color.lightGray
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func hide() {
        height = 0
        navigationBar.sizeToFit()
    }
    
    func show() {
        height = heightDefault
        navigationBar.sizeToFit()
    }
}



extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.height = NavigationBarController.shared.height
        
        return newSize
    }
}

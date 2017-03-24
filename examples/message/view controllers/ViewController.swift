//
//  ViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-28.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


// MARK: - View Controller

class ViewController: UINavigationController, UINavigationControllerDelegate {

    // init with custom navigation bar
    convenience init() {
        self.init(navigationBarClass: AppNavigationBar.classForCoder(), toolbarClass: nil)
    }

    // retaining circle menu
    private var circleMenuController: CircleMenuController!

    // MARK: View Controller Overrides
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        // user interactions enabled while animating by default
        anim.defaultSettings.isUserInteractionsEnabled = true
        
        // configure navigation bar
        NavigationBarController.configure(navigationBar: self.navigationBar)
        NavigationBarController.shared.showProfile()
        self.delegate = self
        
        // circle menu
        circleMenuController = CircleMenuController(parent: self.view)

        // initial view controller
        self.pushViewController(ProfileListViewController(), animated: false)
    }

    // route transitions between view controllers
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        if fromVC is ProfileListViewController && toVC is ProfileDetailViewController && operation == .push {           // profile list -> profile detail
            return ProfileDetailShowAnimator()
        } else if fromVC is ProfileDetailViewController && toVC is ProfileListViewController && operation == .pop {     // profile list <- profile detail
            return ProfileDetailHideAnimator()
        } else if fromVC is MessageListViewController && toVC is MessageDialogueViewController && operation == .push {  // message list -> chat
            return MessageConversationShowAnimator()
        }

        // default animator
        return DefaultAnimator()
    }
}


// MARK: - Navigation Bar Controller

class NavigationBarController {
    static let shared = NavigationBarController()
    
    private static var navigationBar: UINavigationBar!
    
    struct Height {
        var portrait: CGFloat
        var landscape: CGFloat
        
        var heightForOrientation: CGFloat {
            switch UIDevice.current.orientation {
            case .landscapeLeft, .landscapeRight:
                return self.landscape
            default:
                return self.portrait
            }
        }
    }

    static let heightProfile   = Height(portrait: 71, landscape: 51)
    static let heightMessage   = Height(portrait: 89, landscape: 61)
    static let heightHidden    = Height(portrait: 0, landscape: 0)
    
    fileprivate(set) var height: Height
    
    init() {
        height = NavigationBarController.heightProfile
    }

    private var navigationBar: UINavigationBar {
        return NavigationBarController.navigationBar
    }

    // initial configuration, called once
    class func configure(navigationBar: UINavigationBar) {
        self.navigationBar = navigationBar
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        shared.showProfile()
    }
    
    // updates color of navbar
    func update(color: UIColor) {
        navigationBar.backgroundColor = color
    }
    
    
    
    // Formatting functions below doesn't contain any animation.
    // You gotta do it while calling these, or they will change the look instantly.
    
    // formats navbar for profile list screen
    func showProfile() {
        update(color: Color.lightGray)
        height = NavigationBarController.heightProfile
        navigationBar.sizeToFit()
    }

    // formats navbar for chat screen
    func showMessage() {
        height = NavigationBarController.heightMessage
        navigationBar.sizeToFit()
    }

    // hides navbar
    func hide() {
        height = NavigationBarController.heightHidden
        navigationBar.sizeToFit()
    }
}


// MARK: - Navigation Bar

class AppNavigationBar: UINavigationBar {
    
    // resizing navbar
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.height = NavigationBarController.shared.height.heightForOrientation

        return newSize
    }

    // aligning navbar items
    override func layoutSubviews() {
        super.layoutSubviews()

        for view in subviews {
            if view is NavigationBarButton {
                view.center.y = (self.frame.size.height <= 0) ? -view.bounds.size.height * 0.5 : self.center.y
            }
            
            let centerXOffset = 26 + view.bounds.size.width * 0.5

            if view is LeftNavigationBarButton {
                view.center.x = centerXOffset
            } else if view is RightNavigationBarButton {
                view.center.x = frame.size.width - centerXOffset
            }
        }
    }
}


// navbar uses these protocols to position navbar items.

protocol NavigationBarButton {}
protocol LeftNavigationBarButton: NavigationBarButton {}
protocol RightNavigationBarButton: NavigationBarButton {}


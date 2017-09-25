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
        self.init(navigationBarClass: nil, toolbarClass: nil)
        self.isNavigationBarHidden = true
    }

    // retaining circle menu
    private var circleMenuController: CircleMenuController!
    private var appNavbar: AppNavigationBar!

    // MARK: View Controller Overrides
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        // user interactions enabled while animating by default
        anim.defaultSettings.isUserInteractionsEnabled = true

        // navbar
        appNavbar = AppNavigationBar(parent: self.view)
        
        // configure navigation bar
        NavigationBarController.shared.configure(navigationBar: appNavbar, parent: self.view)
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
    
    private var navigationBar: AppNavigationBar!
    private(set) var parent: UIView!
    private var leftItem: UIView?
    private var rightItem: UIView?
    
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

    fileprivate var height: Height = NavigationBarController.heightProfile

    // initial configuration, called once
    func configure(navigationBar:AppNavigationBar, parent: UIView) {
        self.navigationBar = navigationBar
        self.parent = parent

        UIView.alignMultiple(view: navigationBar, to: parent, attributes: [.top, .left, .right])
        showProfile()
    }
    
    // updates color of navbar
    func update(color: UIColor) {
        navigationBar.backgroundColor = color
    }

    // adds left and right items
    func addItems(left: UIView?, right: UIView?) {
        // 26  / 38
        // 45

        self.leftItem?.removeFromSuperview()
        self.rightItem?.removeFromSuperview()

        self.leftItem = left
        self.rightItem = right

        addItem(item: left, horizontalAttribute: .left)
        addItem(item: right, horizontalAttribute: .right)
    }

    func addItem(item: UIView?, horizontalAttribute: NSLayoutAttribute) {
        guard let item = item else {
            return
        }

        item.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstant: CGFloat = (horizontalAttribute == .left) ? 45 : -45
        navigationBar.addSubview(item)
        navigationBar.addConstraints([
                NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: navigationBar, attribute: .top, multiplier: 1, constant: 45),
                NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: navigationBar, attribute: horizontalAttribute, multiplier: 1, constant: horizontalConstant),
            ])
    }
    
    
    // Formatting functions below doesn't contain any animation.
    // You gotta do it while calling these, or they will change the look instantly.
    
    // formats navbar for profile list screen
    func showProfile() {
        update(color: Color.lightGray)
        height = NavigationBarController.heightProfile
        navigationBar.resize()
        parent.layoutIfNeeded()
    }

    // formats navbar for chat screen
    func showMessage() {
        height = NavigationBarController.heightMessage
        navigationBar.resize()
        parent.layoutIfNeeded()
    }

    // hides navbar
    func hide() {
        height = NavigationBarController.heightHidden
        navigationBar.resize()
        parent.layoutIfNeeded()
    }
}


// MARK: - Navigation Bar

class AppNavigationBar: UIView {

    private var heightConstraint: NSLayoutConstraint!

    convenience init(parent: UIView) {
        self.init()

        self.backgroundColor = UIColor.red
        self.translatesAutoresizingMaskIntoConstraints = false
        parent.addSubview(self)

        heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        parent.addConstraint(heightConstraint)
    }

    

    fileprivate func resize() {
        heightConstraint.constant = NavigationBarController.shared.height.heightForOrientation
        self.layoutIfNeeded()
    }

}

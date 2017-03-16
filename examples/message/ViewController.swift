//
//  ViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-28.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


class ViewController: UINavigationController, UINavigationControllerDelegate {

    convenience init() {
        self.init(navigationBarClass: AppNavigationBar.classForCoder(), toolbarClass: nil)
    }

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
        self.pushViewController(MessageDialogueViewController(), animated: false)
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

    fileprivate let heightProfileDefault: CGFloat = 71
    fileprivate let heightMessageDefault: CGFloat = 89
    fileprivate var height: CGFloat = 71

    private var navigationBar: UINavigationBar {
        return NavigationBarController.navigationBar
    }

    class func configure(navigationBar: UINavigationBar) {
        self.navigationBar = navigationBar
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        shared.showProfile()
    }

    func showProfile() {
        height = heightProfileDefault
        navigationBar.backgroundColor = Color.lightGray
        navigationBar.sizeToFit()
    }

    func showMessage(color: UIColor) {
        height = heightMessageDefault
        navigationBar.backgroundColor = color
        navigationBar.sizeToFit()
    }

    func hide() {
        height = 0
        navigationBar.sizeToFit()
    }
}




class AppNavigationBar: UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize = super.sizeThatFits(size)
        newSize.height = NavigationBarController.shared.height

        return newSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()



        for view in subviews {
            if view is NavigationBarButton {
                view.center.y = self.center.y
            }

            if view is LeftNavigationBarButton {
                view.center.x = view.center.y
            } else if view is RightNavigationBarButton {
                view.center.x = frame.size.width - view.center.y
            }
        }
    }
}

protocol NavigationBarButton {}
protocol LeftNavigationBarButton: NavigationBarButton {}
protocol RightNavigationBarButton: NavigationBarButton {}


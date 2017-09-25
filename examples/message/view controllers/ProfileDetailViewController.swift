//
//  ProfileDetailViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-09.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


// MARK: View Controller

class ProfileDetailViewController: UIViewController {

    private let headerHeight = NavigationBarController.Height(portrait: 173, landscape:110)
    
    var backButtonView: BackButton!

    private var headerView: UIView!
    private var bodyContainerView: ContainerView!
    private var headerHeightConstraint: NSLayoutConstraint!
    private var backButtonConstraints: [NSLayoutConstraint]!
    private var backButtonTopConstraint: NSLayoutConstraint!
    private var backButtonLeftConstraint: NSLayoutConstraint!
    private var containerTopConstraint: NSLayoutConstraint!
    private var profilePicture: ProfileCell.ProfilePicture!
    private var profilePictureOriginalPosition: CGPoint!

    
    // MARK: View Controller Overrides

    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        
        // header
        headerView = UIView()
        headerView.backgroundColor = Color.lightGray
        self.view.addSubview(headerView)
        UIView.alignMultiple(view: headerView, to: self.view, attributes: [.left, .top, .right])
        headerHeightConstraint = UIView.align(view: headerView, to: nil, attribute: .height, constant: NavigationBarController.heightProfile.heightForOrientation)

        // back button
        backButtonView = BackButton.create()
        headerView.addSubview(backButtonView)
        backButtonConstraints = backButtonView.snapEdges(to: headerView)
        backButtonLeftConstraint = NSLayoutConstraint(item: backButtonView, attribute: .left, relatedBy: .equal, toItem: headerView, attribute: .left, multiplier: 1, constant: 26)
        backButtonLeftConstraint.priority = UILayoutPriority(rawValue: 999)
        backButtonLeftConstraint.isActive = false
        headerView.addConstraint(backButtonLeftConstraint)
        backButtonTopConstraint = NSLayoutConstraint(item: backButtonView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .top, multiplier: 1, constant: 26)
        backButtonTopConstraint.priority = UILayoutPriority(rawValue: 999)
        backButtonTopConstraint.isActive = false
        headerView.addConstraint(backButtonTopConstraint)

        // body container
        bodyContainerView = ContainerView.create()
        self.view.addSubview(bodyContainerView)
        UIView.alignMultiple(view: bodyContainerView, to: self.view, attributes: [.left, .bottom, .right])
        bodyContainerView.alignTo(headerView: headerView, parent: self.view)

        // text
        let textLabelView = UILabel()
        textLabelView.textColor = Color.lightGray
        textLabelView.numberOfLines = 12
        textLabelView.font = UIFont(name: Font.nameBlokk, size: 18)
        textLabelView.contentMode = .top
        textLabelView.translatesAutoresizingMaskIntoConstraints = false
        bodyContainerView.addSubview(textLabelView)

        UIView.align(view: textLabelView, to: bodyContainerView, attribute: .top, constant: 0)
        UIView.align(view: textLabelView, to: self.view, attribute: .left, constant: 34)
        UIView.align(view: textLabelView, to: self.view, attribute: .right, constant: -34)
        UIView.align(view: textLabelView, to: nil, attribute: .height, constant: 363)

        textLabelView.attributedText = Dummy.text(82).attributedBlock

        // image
        let imageView = UIView()
        imageView.backgroundColor = Color.lightGray
        bodyContainerView.addSubview(imageView)

        UIView.align(view: imageView, to: self.view, attribute: .left, constant: 34)
        UIView.align(view: imageView, to: self.view, attribute: .right, constant: -34)
        UIView.align(view: imageView, to: nil, attribute: .height, constant: 173)

        bodyContainerView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: textLabelView, attribute: .bottom, multiplier: 1, constant: 27),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: bodyContainerView, attribute: .bottom, multiplier: 1, constant: 0)
            ])

        // move header on top of display list
        self.view.addSubview(headerView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.post(name: Event.menuHide, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addListeners()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
    }
    
    
    // MARK: Listeners
    
    private func addListeners() {
        backButtonView.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationChangeHandler), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    private func removeListeners() {
        backButtonView.removeTarget(self, action: #selector(self.backAction), for: .touchUpInside)
        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: Position / Animate

    func startHeaderInAnimation() {

        // header
        anim(constraintParent: self.view) { (settings) -> animClosure in
            settings.ease = .easeInOutQuint
            settings.duration = 1.3
            return {
                self.headerHeightConstraint.constant = self.headerHeight.heightForOrientation
            }
        }

        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutQuint
            settings.duration = 1
            return {
                self.headerView.backgroundColor = Color.all.random
            }
        }


        // back button
        anim(constraintParent: self.view) { (settings) -> animClosure in
            settings.ease = .easeInOutQuint
            settings.duration = 1.3
            return {
                self.headerView.removeConstraints(self.backButtonConstraints)
                self.backButtonView.size(width: 38, height: 38)
                self.backButtonLeftConstraint.isActive = true
                self.backButtonTopConstraint.isActive = true
            }
        }


        backButtonView.layer.cornerRadius = 20
        backButtonView.backgroundColor = Color.lightGray
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInOutQuint
            settings.delay = 0.2
            settings.duration = 0.8
            return {
                self.backButtonView.backgroundColor = UIColor.white
            }
        }
        backButtonView.animateArrowIn()
    }

    func animateHeaderOut(_ completion: @escaping (()->Void)) {
        anim(constraintParent: self.view) { (settings) -> (animClosure) in
            settings.ease = .easeInOutQuint
            settings.duration = 0.6
            return {
                self.headerHeightConstraint.constant = NavigationBarController.heightProfile.heightForOrientation
                self.backButtonTopConstraint.constant = -200
            }
        }

        anim{ (settings) -> (animClosure) in
            settings.ease = .easeInOutQuint
            settings.duration = 0.6
            settings.completion = completion
            return {
                self.headerView.backgroundColor = Color.lightGray
            }
        }
    }

    func position(profilePicture: ProfileCell.ProfilePicture, position: CGPoint) {
        self.profilePictureOriginalPosition = position
        self.profilePicture = profilePicture

        profilePicture.positionIn(view: self.headerView, position: position)

        anim(constraintParent: self.view) { (settings) -> animClosure in
            settings.ease = .easeInOutQuint
            settings.duration = 1.3
            return {
                profilePicture.positionIn(header: self.headerView)
            }
        }

        anim{ (settings) -> animClosure in
            settings.ease = .easeOutQuint
            return {
                profilePicture.adjustViewForHeader()
            }
        }

    }

    func positionBack(_ completion: @escaping (()->Void)) {
        anim(constraintParent: self.view) { (settings) -> animClosure in
            settings.ease = .easeInOutQuint
            settings.duration = 0.7
            settings.completion = completion
            return {
                self.profilePicture.positionBackOnCellWhileOn(header: self.headerView, positionOnCell: self.profilePictureOriginalPosition)
            }
        }

        anim{ (settings) -> animClosure in
            settings.ease = .easeOutQuint
            settings.duration = 0.7
            return {
                self.profilePicture.adjustViewForProfileList()
            }
        }
    }

    func prepareForDetailBodyIn() {
        bodyContainerView.prepareForAnimateIn()
    }

    func animateProfileDetailBodyIn(_ completion: @escaping ()->Void) {
        bodyContainerView.animateIn(completion)
    }

    func animateProfileDetailBodyOut() {
        bodyContainerView.animateOut()
    }

    
    // MARK: Handlers / Actions

    @objc
    func deviceOrientationChangeHandler() {
        headerHeightConstraint.constant = headerHeight.heightForOrientation
        headerView.layoutIfNeeded()
    }
    
    @objc
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }


}


// MARK: - Container Scroll View

extension ProfileDetailViewController {

    class ContainerView: UIScrollView {

        var outConstraint: NSLayoutConstraint!
        var inConstraint: NSLayoutConstraint!
        weak var parent: UIView!

        class func create() -> ContainerView {
            let view = ContainerView()
            view.contentInset = UIEdgeInsetsMake(71, 0, 42, 0)
            view.contentOffset = CGPoint(x: 0, y: -71)
            view.backgroundColor = UIColor.white

            return view
        }
        
        
        // MARK: Position / Animate

        func alignTo(headerView: UIView, parent: UIView) {
            self.parent = parent

            inConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0)
            parent.addConstraint(inConstraint)

            outConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: parent, attribute: .bottom, multiplier: 1, constant: 0)
            outConstraint.priority = UILayoutPriority(rawValue: 999)
            outConstraint.isActive = false
            parent.addConstraint(outConstraint)
        }

        func prepareForAnimateIn() {
            outConstraint.isActive = true
            inConstraint.isActive = false
            parent.layoutIfNeeded()
        }

        func animateIn(_ completion: @escaping ()->Void) {
            self.alpha = 1
            outConstraint.isActive = true
            inConstraint.isActive = false
            anim(constraintParent: parent) { (settings) -> animClosure in
                settings.ease = .easeOutQuint
                settings.delay = 0.3
                settings.duration = 1.8
                settings.completion = completion
                return {
                    self.outConstraint.isActive = false
                    self.inConstraint.isActive = true
                }
            }
        }

        func animateOut() {
            outConstraint.isActive = false
            inConstraint.isActive = true
            anim(constraintParent: parent) { (settings) -> animClosure in
                settings.duration = 0.5
                settings.ease = .easeInSine
                return {
                    self.outConstraint.isActive = true
                    self.inConstraint.isActive = false
                }
            }

            anim { (settings) -> (animClosure) in
                settings.duration = 0.5
                settings.ease = .easeInSine
                return {
                    self.alpha = 0
                }
            }
        }

    }

}

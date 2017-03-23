//
//  CircleMenu.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-28.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

// MARK: - Controller

class CircleMenuController {
    
    enum State {
        case opened, closed
    }
    
    let subMenuRadius: CGFloat = 110
    
    private var parent: UIView
    private var buttonMain: MenuButton
    private var buttonMessage: MenuButton
    private var buttonProfile: MenuButton
    private var state: State = .closed
    private var isHidden: Bool = false
    
    private var runningAnimations = [anim]()
    private var mainButtonBottomConstraint: NSLayoutConstraint!
    
    @discardableResult
    init(parent: UIView) {
        self.parent = parent
        
        // main button
        buttonMain = MenuButton.create(hierarchy: .main, icon: .menu)
        parent.addSubview(buttonMain)
        UIView.align(view: buttonMain, to: parent, attribute: .right, constant: -33)
        mainButtonBottomConstraint = UIView.align(view: buttonMain, to: parent, attribute: .bottom, constant: -23)
        
        // message button
        buttonMessage = MenuButton.create(hierarchy: .sub, icon: .message)
        parent.insertSubview(buttonMessage, belowSubview: buttonMain)
        buttonMessage.anchorTo(button: buttonMain, parent: parent, direction: .vertical)
        buttonMessage.isHidden = true
        
        // profile button
        buttonProfile = MenuButton.create(hierarchy: .sub, icon: .profile)
        parent.insertSubview(buttonProfile, belowSubview: buttonMain)
        buttonProfile.anchorTo(button: buttonMain, parent: parent, direction: .horizontal)
        buttonProfile.isHidden = true
        
        // event listeners
        NotificationCenter.default.addObserver(self, selector: #selector(self.menuToggleHandler), name: Event.menuToggle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.menuStateChangeHandler), name: Event.menuStateChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.hideHandler), name: Event.menuHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showHandler), name: Event.menuShow, object: nil)
    }
    
    
    // MARK: States
    
    private func updateViewsForOpened() {
        stopAllRunningAnimations()
        showSubButtonAnimation(button: buttonMessage, delay: 0)
        showSubButtonAnimation(button: buttonProfile, delay: 0.08)
        deemphasizeMainButtonAnimation()
        
        lockMainButtonTemporarily()
    }
    
    private func updateViewsForClosed() {
        stopAllRunningAnimations()
        hideSubButtonAnimation(button: buttonMessage, delay: 0)
        hideSubButtonAnimation(button: buttonProfile, delay: 0.05)
        emphasizeMainButtonAnimation()
        
        lockMainButtonTemporarily()
    }
    
    private func lockMainButtonTemporarily() {
        buttonMain.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(320)) { 
            self.buttonMain.isEnabled = true
        }
    }
    
    
    // MARK: Animations
    
    private func showSubButtonAnimation(button: MenuButton, delay: TimeInterval) {
        button.isHidden = false
        button.alpha = 0
        button.distanceToAnchor = 0
        button.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5).rotated(by: CGFloat(181).radian)
        
        var a: anim!
        
        // move
        a = anim(constraintParent: parent) { (settings) -> (animClosure) in
            settings.duration = 0.3
            settings.delay = delay
            settings.ease = .easeOutQuint
            return {
                button.distanceToAnchor = -self.subMenuRadius-7
            }
        }
        .then(constraintParent: parent) { (settings) -> animClosure in
            settings.duration = 0.25
            settings.ease = .easeInOutSine
            return {
                button.distanceToAnchor = -self.subMenuRadius+4
            }
        }
        .then(constraintParent: parent) { (settings) -> animClosure in
            settings.duration = 0.27
            settings.ease = .easeInOutSine
            return {
                button.distanceToAnchor = -self.subMenuRadius
            }
        }
        
        runningAnimations.append(a)
        
        // fade in, scale, rotate
        a = anim { (settings) -> (animClosure) in
            settings.duration = 0.5
            settings.delay = delay
            settings.ease = .easeOutQuint
            return {
                button.alpha = 1
                button.transform = CGAffineTransform.identity
            }
        }
        
        runningAnimations.append(a)
    }
    
    private func hideSubButtonAnimation(button: MenuButton, delay: TimeInterval) {
        var a: anim!
        
        a = anim(constraintParent: parent) { (settings) -> animClosure in
            settings.duration = 0.3
            settings.delay = delay
            settings.ease = .easeInQuad
            return {
                button.distanceToAnchor = 0
            }
        }
        
        runningAnimations.append(a)
        
        a = anim { (settings) -> animClosure in
            settings.duration = 0.2
            settings.delay = delay
            settings.ease = .easeInQuint
            return {
                button.alpha = 0
                button.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            }
        }
        
        runningAnimations.append(a)
    }
    
    private func deemphasizeMainButtonAnimation() {
        let a = anim { (settings) -> (animClosure) in
            settings.duration = 0.2
            settings.ease = .easeOutQuint
            return {
                self.buttonMain.circleRedView.backgroundColor = Color.darkGray
            }
        }
        
        runningAnimations.append(a)
    }
    
    private func emphasizeMainButtonAnimation() {
        let a = anim { (settings) -> (animClosure) in
            settings.duration = 0.3
            settings.ease = .easeInSine
            return {
                self.buttonMain.circleRedView.backgroundColor = Color.red
            }
        }
        
        runningAnimations.append(a)
    }
    
    private func stopAllRunningAnimations() {
        runningAnimations.forEach { (anim) in
            anim.stop()
        }
        
        runningAnimations.removeAll()
    }
    
    @objc
    func menuToggleHandler() {
        let newState: State = (state == .closed) ? .opened : .closed
        NotificationCenter.default.post(name: Event.menuStateChange, object: nil, userInfo: ["state": newState])
    }
    
    @objc
    func menuStateChangeHandler(notification: Notification) {
        guard let newState = notification.userInfo?["state"] as? State else { return }
        state = newState
        
        switch self.state {
        case .closed:
            self.updateViewsForClosed()
        default:
            self.updateViewsForOpened()
        }
    }
    
    @objc
    func hideHandler() {
        if state == .opened {
            NotificationCenter.default.post(name: Event.menuToggle, object: nil)
        }
        
        anim(constraintParent: parent) { (settings) -> animClosure in
            settings.ease = .easeInSine
            settings.duration = 0.4
            return {
                self.mainButtonBottomConstraint.constant = 120
            }
        }
    }
    
    @objc
    func showHandler() {
        anim(constraintParent: parent) { (settings) -> animClosure in
            settings.ease = .easeOutBack
            settings.duration = 0.5
            return {
                self.mainButtonBottomConstraint.constant = -23
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


// MARK: - Button

class MenuButton: UIButton {
    
    enum Hierarchy {
        case main, sub
    }
    
    enum Icon {
        case none, menu, message, profile
    }
    
    enum Direction {
        case horizontal, vertical
    }
    
    var circleRedView: UIView!
    private var circleWhiteView: UIView!
    private var iconView: UIView!
    private var icon: Icon!
    private var anchorConstraint: NSLayoutConstraint?
    private var circleWhiteScale: CGFloat = 1
    private var circleRedScale: CGFloat = 1
    
    var distanceToAnchor: CGFloat {
        get {
            return (anchorConstraint?.constant ?? 0)
        }
        set {
            anchorConstraint?.constant = newValue
        }
    }
    
    var whiteScale: CGFloat {
        get {
            return circleWhiteScale
        }
        set {
            circleWhiteScale = newValue
            circleWhiteView.transform = CGAffineTransform.identity.scaledBy(x: circleWhiteScale, y: circleWhiteScale)
        }
    }
    
    var redScale: CGFloat {
        get {
            return circleRedScale
        }
        set {
            circleRedScale = newValue
            circleRedView.transform = CGAffineTransform.identity.scaledBy(x: circleRedScale, y: circleRedScale)
        }
    }
    
    class func create(hierarchy: Hierarchy, icon: Icon) -> MenuButton {
        
        let view = MenuButton()
        view.icon = icon
        
        // add views
        view.circleWhiteView = UIView()
        view.circleWhiteView.backgroundColor = UIColor.white
        view.circleWhiteView.isUserInteractionEnabled = false
        view.addSubview(view.circleWhiteView)
        
        view.circleRedView = UIView()
        view.circleRedView.backgroundColor = Color.red
        view.circleRedView.isUserInteractionEnabled = false
        view.addSubview(view.circleRedView)
        
        // size views
        switch hierarchy {
        case .main:
            view.size(width: 87, height: 87)
            view.circleWhiteView.size(width: 87, height: 87)
            view.circleWhiteView.layer.cornerRadius = 44
            view.circleRedView.size(width: 67, height: 67)
            view.circleRedView.layer.cornerRadius = 34
        case .sub:
            view.size(width: 71, height: 71)
            view.circleWhiteView.size(width: 71, height: 71)
            view.circleWhiteView.layer.cornerRadius = 36
            view.circleRedView.size(width: 53, height: 53)
            view.circleRedView.layer.cornerRadius = 27
        }
        
        // prepare icons
        switch icon {
        case .menu:
            view.prepareIconMenu()
        case .message:
            view.prepareIconMessage()
        case .profile:
            view.prepareIconProfile()
        default: break
        }
        
        // center content
        view.circleWhiteView.center(to: view)
        view.circleRedView.center(to: view)
        
        // add listeners
        view.addListeners()
        
        return view
    }
    
    
    // MARK: Position
    
    fileprivate func anchorTo(button: MenuButton, parent: UIView, direction: Direction) {
        let xConstraint = UIView.align(view: self, to: button, attribute: .centerX, constant: 0, parent: parent)
        let yConstraint = UIView.align(view: self, to: button, attribute: .centerY, constant: 0, parent: parent)
        
        if direction == .horizontal {
            anchorConstraint = xConstraint
        } else {
            anchorConstraint = yConstraint
        }
    }
    
    private func prepareIconMenu() {
        iconView = HamburgerIcon.create()
        self.addSubview(iconView)
        iconView.center(to: self)
    }
    
    private func prepareIconMessage() {
        iconView = MessageIcon.create()
        self.addSubview(iconView)
        iconView.center(to: self, verticalAdjustment: 2)
    }
    
    private func prepareIconProfile() {
        iconView = ProfileIcon.create()
        self.addSubview(iconView)
        iconView.center(to: self, verticalAdjustment: 5)
    }
    
    // MARK: Listeners
    
    private func addListeners() {
        self.addTarget(self, action: #selector(self.downAction), for: .touchDown)
        self.addTarget(self, action: #selector(self.tapAction), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.cancelAction), for: .touchCancel)
        self.addTarget(self, action: #selector(self.cancelAction), for: .touchUpOutside)
        
        if icon == .menu {
            NotificationCenter.default.addObserver(self, selector: #selector(self.menuStateChangeHandler), name: Event.menuStateChange, object: nil)
        }
    }
    
    private func removeListeners() {
        self.removeTarget(self, action: #selector(self.downAction), for: .touchDown)
        self.removeTarget(self, action: #selector(self.tapAction), for: .touchUpInside)
        self.removeTarget(self, action: #selector(self.cancelAction), for: .touchCancel)
        self.removeTarget(self, action: #selector(self.cancelAction), for: .touchUpOutside)
        
        if icon == .menu {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    
    // MARK: Handlers / Actions
    
    @objc
    func tapAction() {
        
        if icon == .menu {
            NotificationCenter.default.post(name: Event.menuToggle, object: nil)
        } else if icon == .profile {
            NotificationCenter.default.post(name: Event.navigateToProfile, object: nil)
            NotificationCenter.default.post(name: Event.menuToggle, object: nil)
        } else if icon == .message {
            NotificationCenter.default.post(name: Event.navigateToMessages, object: nil)
            NotificationCenter.default.post(name: Event.menuToggle, object: nil)
        }
        
        cancelAction()
    }
    
    @objc
    func downAction() {
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutBack
            settings.duration = 0.16
            return {
                self.whiteScale = 1.2
                self.redScale = 0.9
            }
        }
    }
    
    @objc
    func cancelAction() {
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutQuint
            settings.duration = 0.4
            return {
                self.whiteScale = 1
                self.redScale = 1
            }
        }
    }
    
    @objc
    func menuStateChangeHandler(notification: Notification) {
        guard let hamburgerIconView = iconView as? HamburgerIcon else { return }
        guard let menuState = notification.userInfo?["state"] as? CircleMenuController.State else { return }
        
        switch menuState {
        case .closed:
            hamburgerIconView.updateIconToHamburger()
        case .opened:
            hamburgerIconView.updateIconToClose()
        }
    }
    
    deinit {
        removeListeners()
    }
}


// MARK: - Hamburger Icon Single Line

extension MenuButton {
    
    class HamburgerLine: UIView {
        
        class func create() -> HamburgerLine {
            let view = HamburgerLine(frame: CGRect(x: 0, y: 0, width: 27, height: 4))
            view.backgroundColor = UIColor.white
            
            return view
        }
        
    }
}


// MARK: - Hamburger Icon

extension MenuButton {
    
    class HamburgerIcon: UIView {
        
        var line1View: HamburgerLine!
        var line2View: HamburgerLine!
        var line3View: HamburgerLine!
        
        class func create() -> HamburgerIcon {
            let view = HamburgerIcon()
            
            view.line1View = HamburgerLine.create()
            view.line1View.center = CGPoint(x: 0, y: -10)
            view.addSubview(view.line1View)
            
            view.line2View = HamburgerLine.create()
            view.line2View.center = CGPoint(x: 0, y: 0)
            view.addSubview(view.line2View)
            
            view.line3View = HamburgerLine.create()
            view.line3View.center = CGPoint(x: 0, y: 10)
            view.addSubview(view.line3View)
            
            return view
        }
        
        
        // MARK: Hamburger State
        
        func updateIconToHamburger() {
            
            // top bar
            anim { (settings) -> (animClosure) in
                settings.duration = 0.4
                settings.ease = .easeOutBack
                return {
                    self.line1View.transform = CGAffineTransform.identity
                }
            }
            anim { (settings) -> (animClosure) in
                settings.duration = 0.3
                settings.ease = .easeInOutQuint
                return {
                    self.line1View.center = CGPoint(x: 0, y: -10)
                }
            }
            
            // bottom bar
            anim { (settings) -> (animClosure) in
                settings.duration = 0.5
                settings.ease = .easeOutBack
                return {
                    self.line3View.transform = CGAffineTransform.identity
                }
            }
            anim { (settings) -> (animClosure) in
                settings.duration = 0.4
                settings.ease = .easeInOutQuint
                return {
                    self.line3View.center = CGPoint(x: 0, y: 10)
                }
            }
            
            // middle bar
            anim { (settings) -> (animClosure) in
                settings.delay = 0.1
                settings.duration = 0.3
                settings.ease = .easeOutQuint
                return {
                    self.line2View.center = CGPoint(x: 0, y: 0)
                    self.line2View.transform = CGAffineTransform.identity
                    self.line2View.alpha = 1
                }
            }
            
        }
        
        
        // MARK: Close State
        
        func updateIconToClose() {
            
            // middle bar
            anim { (settings) -> (animClosure) in
                settings.duration = 0.2
                settings.ease = .easeInSine
                return {
                    self.line2View.alpha = 0
                    self.line2View.transform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)
                }
            }
            
            
            // top bar
            anim { (settings) -> (animClosure) in
                settings.duration = 0.4
                settings.ease = .easeOutBack
                return {
                    self.line1View.transform = CGAffineTransform.identity.rotated(by: CGFloat(45).radian)
                }
            }
            
            anim { (settings) -> (animClosure) in
                settings.duration = 0.5
                settings.ease = .easeInOutQuint
                return {
                    self.line1View.center = CGPoint(x: 0, y: 0)
                }
            }
            
            
            // bottom bar
            anim { (settings) -> (animClosure) in
                settings.duration = 0.4
                settings.ease = .easeOutBack
                return {
                    self.line3View.transform = CGAffineTransform.identity.rotated(by: CGFloat(-45).radian)
                }
            }
            
            anim { (settings) -> (animClosure) in
                settings.duration = 0.6
                settings.ease = .easeOutQuint
                return {
                    self.line3View.center = CGPoint(x: 0, y: 0)
                }
            }
            
        }
        
    }
}


// MARK: - Message Icon

extension MenuButton {
    
    class MessageIcon: UIImageView {
        class func create() -> MessageIcon {
            let view = MessageIcon()
            view.image = #imageLiteral(resourceName: "circlemenu_icon_message")
            return view
        }
    }
    
}


// MARK: - Profile Icon

extension MenuButton {
    
    class ProfileIcon: UIImageView {
        class func create() -> ProfileIcon {
            let view = ProfileIcon()
            view.image = #imageLiteral(resourceName: "circlemenu_icon_profile")
            return view
        }
    }
    
}

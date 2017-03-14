//
//  MessageListViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-14.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

class MessageListViewController: UIViewController {
    
    var scrollView: UIScrollView!
    var bubbleContainer: UIView!
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        scrollView = BubbleScrollView.create()
        self.view.addSubview(scrollView)
        scrollView.snapEdges(to: self.view)
        
        bubbleContainer = UIView()
        bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(bubbleContainer)
        
        var lastBubble: ConversationBubble? = nil
        for _ in 0..<13 {
            let bubble = ConversationBubble.create()
            bubble.position(on: bubbleContainer, under: lastBubble)
            bubble.animateFloating()
            lastBubble = bubble
        }
        
        if let lastBubble = lastBubble {
            self.view.addConstraints([
                NSLayoutConstraint(item: bubbleContainer, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: bubbleContainer, attribute: .bottom, relatedBy: .equal, toItem: lastBubble, attribute: .bottom, multiplier: 1, constant: 0)
                ])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarController.shared.hide()
    }
    
}

class BubbleScrollView: UIScrollView, UIScrollViewDelegate {
    
    
    var previousOffset: CGPoint?
    var velocity: CGPoint = CGPoint.zero
    
    class func create() -> BubbleScrollView {
        let view = BubbleScrollView()
        
        view.delegate = view
        view.bounces = false
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let containerFrame = subviews.first?.frame else {
            return
        }
        
        contentSize = containerFrame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            previousOffset = contentOffset
        }
        
        guard let previousOffset = previousOffset else {
            return
        }
        
        if contentOffset.y <= 0 || contentOffset.y + scrollView.frame.size.height >= contentSize.height  {
            let currentVelocity = contentOffset - previousOffset
            velocity = CGPoint.lerp(current: velocity, target: currentVelocity, t: 0.5)
            NotificationCenter.default.post(name: Event.ConversationScroll, object: nil, userInfo: ["velocity": velocity])
        }
    }
}

class ConversationBubble: UIButton {
    
    private(set) var positionConstraints: BubbleConstraints!
    private(set) var floatingContainer: UIView!
    private var animation: anim?
    
    class func create() -> ConversationBubble {
        let view = ConversationBubble()
        
        view.floatingContainer = UIView()
        view.addSubview(view.floatingContainer)
        view.floatingContainer.backgroundColor = Color.lightGray
        view.floatingContainer.isUserInteractionEnabled = false
        
        view.positionConstraints = BubbleConstraints(for: view)
        view.backgroundColor = UIColor.clear
        
        view.addTarget(view, action: #selector(self.tapAction), for: .touchUpInside)
        NotificationCenter.default.addObserver(view, selector: #selector(self.scrollHandler), name: Event.ConversationScroll, object: nil)
        
        return view
    }
    
    func position(on parent: UIView, under: ConversationBubble? = nil) {
        positionConstraints.place(at: parent, under: under)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionConstraints.updateCornerRadius()
    }
    
    func animateFloating() {
        self.floatToNewPosition()
    }
    
    private func floatToNewPosition() {
        guard let parent = positionConstraints.parent else {
            return
        }
        
        let randomPosition = CGFloat(10).randomPointWithRadius
        
        let randomDuration = DoubleRange(min: 1.2, max: 3.3).random
        let randomDelay = DoubleRange(min: 0, max: 0.2).random
        
        animation = anim(constraintParent: parent) { (settings) -> animClosure in
            settings.ease = .easeInOutSine
            settings.duration = randomDuration
            settings.delay = randomDelay
            settings.isUserInteractionsEnabled = true
            settings.completion = self.floatToNewPosition
            return {
                self.positionConstraints.positionFloatingContainer(x: randomPosition.x, y: randomPosition.y)
            }
        }
        
    }
    
    private func bounceOnEndScroll(withVelocity velocity: CGFloat) {
        guard let parent = positionConstraints.parent else {
            return
        }
        
        stopAnimation()
        
        let initialDuration = DoubleRange(min: 0.2, max: 0.3).random
        let initialHorizontalDrift = DoubleRange(min: -0.4, max: 0.4).random.cgFloat
        let initialVelocityMultiplier = DoubleRange(min: 2.6, max: 3.8).random.cgFloat
        
        animation = anim(constraintParent: parent) { (settings) -> animClosure in
            settings.ease = .easeOutQuad
            settings.duration = initialDuration
            settings.isUserInteractionsEnabled = true
            return {
                self.positionConstraints.positionFloatingContainer(x: velocity*initialHorizontalDrift, y: velocity*initialVelocityMultiplier)
            }
        }
        .then(constraintParent: parent, { (settings) -> animClosure in
            settings.ease = .easeInOutQuad
            settings.duration = 0.4
            settings.isUserInteractionsEnabled = true
            return {
                self.positionConstraints.positionFloatingContainer(x: 0, y: -velocity*1.4)
            }
        })
        .then(constraintParent: parent, { (settings) -> animClosure in
            settings.ease = .easeInOutSine
            settings.duration = 0.5
            settings.isUserInteractionsEnabled = true
            return {
                self.positionConstraints.positionFloatingContainer(x: 0, y: 0)
            }
        })
        .callback {
            self.animateFloating()
        }
    }
    
    func stopAnimation() {
        animation?.stop()
        animation = nil
    }
    
    
    @objc
    func tapAction() {
        print("tap")
    }
    
    @objc
    func scrollHandler(notification: Notification) {
        guard let velocity = notification.userInfo?["velocity"] as? CGPoint else {
            return
        }
        
        let limit: CGFloat = 18
        let velocityY = max(min(velocity.y, limit), -limit)
        bounceOnEndScroll(withVelocity: velocityY)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeTarget(self, action: #selector(self.tapAction), for: .touchUpInside)
    }
}

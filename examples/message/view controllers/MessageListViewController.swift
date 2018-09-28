//
//  MessageListViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-14.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


// MARK: - View Controller

class MessageListViewController: UIViewController {
    
    fileprivate var scrollView: BubbleScrollView!
    private(set) var bubbleTransitionFrame: CGRect?
    private var animatingBubble: ConversationBubble?
    
    
    // MARK: View Controller Overrides
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false
        
        scrollView = BubbleScrollView.create()
        self.view.addSubview(scrollView)
        scrollView.size(withMainView: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addListeners()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        animatingBubble?.restoreAnimateDown()
        animatingBubble = nil
    }
    
    
    // MARK: Listeners
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToConversationHandler), name: AnimEvent.navigateToConversation, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToProfileHandler), name: AnimEvent.navigateToProfile, object: nil)
    }
    
    private func removeListeners() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func navigateToConversationHandler(notification: Notification) {
        guard animatingBubble == nil else {
            return
        }
        
        guard let bubble = notification.object as? ConversationBubble else {
            return
        }
        
        bubbleTransitionFrame = scrollView.bubbleContainer.convert(bubble.frame, to: self.view)
        animatingBubble = bubble
        bubble.animateDown {
            self.navigationController?.pushViewController(MessageDialogueViewController(), animated: true)
        }
    }
    
    @objc
    func navigateToProfileHandler(notification: Notification) {
        self.navigationController?.pushViewController(ProfileListViewController(), animated: true)
        self.navigationController?.viewControllers.remove(at: 0)
    }
}


// MARK: - View Controller Transition Animations

extension MessageListViewController: AnimatedViewController {
    var estimatedInAnimationDuration: TimeInterval {
        return 0.5
    }
    var estimatedOutAnimationDuration: TimeInterval {
        return 0.6
    }
    
    func animateIn(_ completion: @escaping ()->Void) {
        NotificationCenter.default.post(name: AnimEvent.menuShow, object: nil)

        anim { (settings) -> (animClosure) in
            settings.duration = 0.6
            settings.ease = .easeInQuint
            return {
                NavigationBarController.shared.hide()
            }
        }
        
        self.scrollView.animateIn()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(estimatedInAnimationDuration*1000))) {
            completion()
        }
    }
    
    func animateOut(_ completion: @escaping ()->Void) {
        self.scrollView.animateOut()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(estimatedOutAnimationDuration*1000))) {
            completion()
        }
    }
    
    func prepareForAnimateIn() {
        self.scrollView.prepareAnimateIn()
    }
    
    func prepareForAnimateOut() {}
}


// MARK: - Bubble Scroll View

class BubbleScrollView: UIScrollView, UIScrollViewDelegate {
    
    static fileprivate let bubbleCount = 13
    static fileprivate let inAnimationDelayBetweenBubbles = 0.08
    static fileprivate let outAnimationDelayBetweenBubbles = 0.04
    
    private(set) var bubbleContainer: UIView!
    private var previousOffset: CGPoint?
    private var velocity: CGPoint = CGPoint.zero
    private var bubbles: [ConversationBubble]?
    
    var bubblesInScreen: [ConversationBubble] {
        guard let bubbles = bubbles else {
            return [ConversationBubble]()
        }
        
        var array = [ConversationBubble]()
        for bubble in bubbles {
            if !(bubble.frame.origin.y+bubble.frame.size.height < contentOffset.y || bubble.frame.origin.y > contentOffset.y+frame.size.height) {
                array.append(bubble)
            }
        }
        
        return array
    }
    
    class func create() -> BubbleScrollView {
        let view = BubbleScrollView()
        
        view.delegate = view
        view.bounces = false
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0)
        
        view.bubbleContainer = UIView()
        view.bubbleContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(view.bubbleContainer)
        
        view.bubbles = [ConversationBubble]()
        var lastBubble: ConversationBubble? = nil
        for _ in 0..<bubbleCount {
            let bubble = ConversationBubble.create()
            bubble.position(on: view.bubbleContainer, under: lastBubble)
            bubble.animateFloating()
            view.bubbles?.append(bubble)
            lastBubble = bubble
        }
        
        return view
    }
    
    func size(withMainView mainView: UIView) {
        self.snapEdges(to: mainView)
        
        guard let lastBubble = bubbles?.last else {
            return
        }
        
        mainView.addConstraints([
            NSLayoutConstraint(item: bubbleContainer, attribute: .width, relatedBy: .equal, toItem: mainView, attribute: .width, multiplier: 1, constant: 0)
            ])
        
        self.addConstraints([
            NSLayoutConstraint(item: bubbleContainer, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bubbleContainer, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: bubbleContainer, attribute: .bottom, relatedBy: .equal, toItem: lastBubble, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let containerFrame = subviews.first?.frame else {
            return
        }
        
        contentSize = containerFrame.size
    }
    
    
    // MARK: Scroll View Delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        defer {
            previousOffset = contentOffset
        }
        
        guard let previousOffset = previousOffset else {
            return
        }
        
        if contentOffset.y <= 0 || contentOffset.y + scrollView.frame.size.height - contentInset.bottom >= contentSize.height  {
            NotificationCenter.default.post(name: AnimEvent.conversationScroll, object: nil, userInfo: ["velocity": velocity])
        }
        
        let currentVelocity = contentOffset - previousOffset
        velocity = CGPoint.lerp(current: velocity, target: currentVelocity, t: 0.5)
    }
    
    
    // MARK: Position / Animate
    
    func prepareAnimateIn() {
        bubbles?.forEach { (bubble) in
            bubble.prepareAnimateIn()
        }
    }
    
    func animateIn() {
        guard let bubbles = bubbles else {
            return
        }
        
        for (index, bubble) in bubbles.enumerated() {
            bubble.animateIn(delay: Double(index) * BubbleScrollView.inAnimationDelayBetweenBubbles)
        }
    }
    
    func animateOut() {
        let bubblesReverseEnumerated = bubblesInScreen.reversed().enumerated()
        for (index, bubble) in bubblesReverseEnumerated {
            bubble.animateOut(delay: Double(index) * BubbleScrollView.outAnimationDelayBetweenBubbles)
        }
    }
}


// MARK: - Conversation Bubble

class ConversationBubble: UIButton {
    
    static fileprivate let outAnimationDuration: TimeInterval = 0.35
    static fileprivate let inAnimationDuration: TimeInterval = 1
    
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
        NotificationCenter.default.addObserver(view, selector: #selector(self.scrollHandler), name: AnimEvent.conversationScroll, object: nil)
        
        return view
    }
    
    func position(on parent: UIView, under: ConversationBubble? = nil) {
        positionConstraints.place(at: parent, under: under)
    }
    
    
    // MARK: View Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        positionConstraints.updateCornerRadius()
    }
    
    
    // MARK: Floating Animation
    
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
    
    
    // MARK: Position / Animate (Shared)
    
    func stopAnimation() {
        animation?.stop()
        animation = nil
    }
    
    
    // MARK: Bounce On Edge Animation
    
    private func bounceOnEndScroll(withVelocity velocity: CGFloat) {
        guard let parent = positionConstraints.parent else {
            return
        }
        
        stopAnimation()
        
        let initialDuration = DoubleRange(min: 0.18, max: 0.28).random
        let initialHorizontalDrift = DoubleRange(min: -0.4, max: 0.4).random.cgFloat
        let initialVelocityMultiplier = DoubleRange(min: 2.1, max: 2.9).random.cgFloat
        
        animation = anim(constraintParent: parent) { (settings) -> animClosure in
            settings.ease = .easeOutQuad
            settings.duration = initialDuration
            settings.isUserInteractionsEnabled = true
            return {
                self.positionConstraints.positionFloatingContainer(x: velocity*initialHorizontalDrift, y: -velocity*initialVelocityMultiplier)
            }
        }
        .then(constraintParent: parent, { (settings) -> animClosure in
            settings.ease = .easeInOutQuad
            settings.duration = 0.4
            settings.isUserInteractionsEnabled = true
            return {
                self.positionConstraints.positionFloatingContainer(x: 0, y: velocity*0.3)
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
    
    
    // MARK: In Animation
    
    func prepareAnimateIn() {
        stopAnimation()
        
        self.positionConstraints.positionFloatingContainer(x: 0, y: 200)
        self.alpha = 0
    }
    
    func animateIn(delay: TimeInterval) {
        guard let parent = positionConstraints.parent else {
            return
        }
        
        anim { (settings) -> (animClosure) in
            settings.duration = 0.4
            settings.delay = delay
            return {
                self.alpha = 1
            }
        }
        
        anim(constraintParent: parent) { (settings) -> animClosure in
            settings.duration = ConversationBubble.inAnimationDuration * 0.5
            settings.ease = .easeOutQuint
            settings.delay = delay
            return {
                self.positionConstraints.positionFloatingContainer(x: 0, y: -10)
            }
        }
        .then(constraintParent: parent, { (settings) -> animClosure in
            settings.duration = ConversationBubble.inAnimationDuration * 0.5
            settings.ease = .easeInOutQuad
            return {
                self.positionConstraints.positionFloatingContainer(x: 0, y: 0)
            }
        })
        .callback {
            self.animateFloating()
        }
        
    }
    
    
    // MARK: Out Animation
    
    func animateOut(delay: TimeInterval) {
        guard let parent = positionConstraints.parent else {
            return
        }
        
        stopAnimation()
        
        anim { (settings) -> (animClosure) in
            settings.duration = ConversationBubble.outAnimationDuration
            settings.ease = .easeInQuint
            settings.delay = delay
            return {
                self.alpha = 0
            }
        }
        
        anim(constraintParent: parent) { (settings) -> animClosure in
            settings.duration = ConversationBubble.outAnimationDuration
            settings.ease = .easeInQuint
            settings.delay = delay
            return {
                self.positionConstraints.positionFloatingContainer(x: 0, y: 200)
            }
        }
    }
    
    
    // MARK: Down Animation
    
    func animateDown(_ completion: @escaping ()->Void) {
        
        
        anim { (settings) -> (animClosure) in
            settings.duration = 0.15
            settings.ease = .easeOutQuint
            return {
                self.transform = CGAffineTransform.identity.scaledBy(x: 0.93, y: 0.93)
                self.floatingContainer.backgroundColor = Color.midGray
            }
        }
        .callback {
            completion()
        }
    }
    
    func restoreAnimateDown() {
        self.transform = CGAffineTransform.identity
        self.floatingContainer.backgroundColor = Color.lightGray
    }
    
    
    // MARK: Actions / Handlers
    
    @objc
    func tapAction() {
        NotificationCenter.default.post(name: AnimEvent.navigateToConversation, object: self)
    }
    
    @objc
    func scrollHandler(notification: Notification) {
        guard let velocity = notification.userInfo?["velocity"] as? CGPoint else {
            return
        }
        
        let limit: CGFloat = 28
        let velocityY = max(min(velocity.y, limit), -limit)
        bounceOnEndScroll(withVelocity: velocityY)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        removeTarget(self, action: #selector(self.tapAction), for: .touchUpInside)
    }
}

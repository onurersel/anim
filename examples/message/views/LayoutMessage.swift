//
//  LayoutMessage.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-14.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

class BubbleConstraints {
    
    private let defaultDistanceBetweenTwoBubbles: CGFloat = 140
    
    enum Side {
        case left, right
    }
    
    weak private var child: ConversationBubble?
    
    var parent: UIView?
    var widthConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var xConstraint: NSLayoutConstraint?
    var yConstraint: NSLayoutConstraint?
    var xFloatConstraint: NSLayoutConstraint?
    var yFloatConstraint: NSLayoutConstraint?
    var side: Side?
    var floatingContainerSizeConstraints: [NSLayoutConstraint]?
    var floatingContainerXConstraint: NSLayoutConstraint?
    var floatingContainerYConstraint: NSLayoutConstraint?
    
    init(`for` child: ConversationBubble) {
        self.child = child
        
        child.translatesAutoresizingMaskIntoConstraints = false
        child.floatingContainer.translatesAutoresizingMaskIntoConstraints = false
        
        // limiting width
        child.addConstraint(
            NSLayoutConstraint(item: child, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 240)
        )
    }
    
    func place(at parent: UIView, under: ConversationBubble? = nil) {
        removeFromParent()
        
        self.parent = parent
        
        guard let child = child else {
            return
        }
        
        parent.addSubview(child)
        
        if let previousSide = under?.positionConstraints.side {
            side = (previousSide == .left) ? .right : .left
        } else {
            side = .left
        }
        
        let xPercent: CGFloat = (side == .left) ? 0.297 : 0.703
        
        widthConstraint = NSLayoutConstraint(item: child, attribute: .width, relatedBy: .equal, toItem: parent, attribute: .width, multiplier: 0.47, constant: 0)
        widthConstraint!.priority = 999
        heightConstraint = NSLayoutConstraint(item: child, attribute: .height, relatedBy: .equal, toItem: child, attribute: .width, multiplier: 1, constant: 0)
        xConstraint = NSLayoutConstraint(item: child, attribute: .centerX, relatedBy: .equal, toItem: parent, attribute: .right, multiplier: xPercent, constant: 0)
        yConstraint = NSLayoutConstraint(item: child, attribute: .centerY, relatedBy: .equal, toItem: (under ?? parent), attribute: (under == nil ? .top : .centerY), multiplier: 1, constant: defaultDistanceBetweenTwoBubbles)
        
        parent.addConstraints([widthConstraint!, xConstraint!, yConstraint!])
        child.addConstraint(heightConstraint!)
        
        
        floatingContainerSizeConstraints = [
            NSLayoutConstraint(item: child.floatingContainer, attribute: .width, relatedBy: .equal, toItem: child, attribute: .width, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: child.floatingContainer, attribute: .height, relatedBy: .equal, toItem: child, attribute: .height, multiplier: 1, constant: 0)
        ]
        floatingContainerXConstraint = NSLayoutConstraint(item: child.floatingContainer, attribute: .centerX, relatedBy: .equal, toItem: child, attribute: .centerX, multiplier: 1, constant: 0)
        floatingContainerYConstraint = NSLayoutConstraint(item: child.floatingContainer, attribute: .centerY, relatedBy: .equal, toItem: child, attribute: .centerY, multiplier: 1, constant: 0)
        
        child.addConstraints(floatingContainerSizeConstraints! + [floatingContainerXConstraint!, floatingContainerYConstraint!])
        
    }
    
    func removeFromParent() {
        guard let parent = parent, let child = child else {
            return
        }
        
        if let widthConstraint = widthConstraint { parent.removeConstraint(widthConstraint) }
        if let xConstraint = xConstraint { parent.removeConstraint(xConstraint) }
        if let yConstraint = xConstraint { parent.removeConstraint(yConstraint) }
        if let heightConstraint = heightConstraint { child.removeConstraint(heightConstraint) }
        
        if let floatingContainerSizeConstraints = floatingContainerSizeConstraints { child.removeConstraints(floatingContainerSizeConstraints) }
        if let floatingContainerXConstraint = floatingContainerXConstraint { child.removeConstraint(floatingContainerXConstraint) }
        if let floatingContainerYConstraint = floatingContainerYConstraint { child.removeConstraint(floatingContainerYConstraint) }
        
        child.removeFromSuperview()
        
        
    }
    
    func updateCornerRadius() {
        guard let child = child else {
            return
        }
        
        child.floatingContainer.layer.cornerRadius = child.floatingContainer.frame.size.width/2.0
    }
    
    func position(x: CGFloat, y: CGFloat) {
        xConstraint?.constant = x
        yConstraint?.constant = defaultDistanceBetweenTwoBubbles + y
    }
    
    func positionFloatingContainer(x: CGFloat, y: CGFloat) {
        floatingContainerXConstraint?.constant = x
        floatingContainerYConstraint?.constant = y
    }
    
}

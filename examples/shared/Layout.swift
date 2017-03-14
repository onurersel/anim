//
//  Layout.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

extension UIView {
    @discardableResult
    func snapEdges(to: UIView, offset: CGFloat = 0) -> [NSLayoutConstraint] {
        return UIView.alignMultiple(view: self, to: to, attributes: [.left, .right, .top, .bottom], constant: offset)
    }
    
    @discardableResult
    func center(to: UIView, horizontalAdjustment: CGFloat = 0, verticalAdjustment: CGFloat = 0, parent: UIView? = nil) -> [NSLayoutConstraint] {
        return [
            UIView.align(view: self, to: to, attribute: .centerX, constant: horizontalAdjustment, parent: parent),
            UIView.align(view: self, to: to, attribute: .centerY, constant: verticalAdjustment, parent: parent)
        ]
    }
    
    func bottom(to: UIView, verticalAdjustment: CGFloat = 0) {
        UIView.align(view: self, to: to, attribute: .centerX, constant: 0)
        UIView.align(view: self, to: to, attribute: .bottom, constant: verticalAdjustment)
    }
    
    func bottomRight(to: UIView, rightMargin: CGFloat = 0, bottomMargin: CGFloat = 0) {
        UIView.align(view: self, to: to, attribute: .right, constant: rightMargin)
        UIView.align(view: self, to: to, attribute: .bottom, constant: bottomMargin)
    }
    
    @discardableResult
    func size(width: CGFloat, height: CGFloat) -> [NSLayoutConstraint] {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        return [
            UIView.align(view: self, to: nil, attribute: .width, constant: width),
            UIView.align(view: self, to: nil, attribute: .height, constant: height)
        ]
    }
    
    @discardableResult
    class func alignMultiple(view: UIView, to: UIView?, attributes: [NSLayoutAttribute], constant: CGFloat = 0, parent: UIView? = nil) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        for attr in attributes {
            constraints.append( align(view: view, to: to, attribute: attr, constant: constant, parent: parent) )
        }
        
        return constraints
    }
    
    @discardableResult
    class func align(view: UIView, to: UIView?, attribute: NSLayoutAttribute, constant: CGFloat = 0, parent: UIView? = nil) -> NSLayoutConstraint {
        view.translatesAutoresizingMaskIntoConstraints = false
        let c = NSLayoutConstraint(item: view,
                                   attribute: attribute,
                                   relatedBy: .equal,
                                   toItem: to,
                                   attribute: (to == nil) ? .notAnAttribute : attribute,
                                   multiplier: 1,
                                   constant: constant)
        ((parent ?? to) ?? view).addConstraint(c)
        return c
    }
}

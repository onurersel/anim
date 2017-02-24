//
//  Layout.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

extension UIView {
    func snapEdges(to: UIView) {
        disableTranslation()
        UIView.alignMultiple(parent: to, child: self, attributes: [.left, .right, .top, .bottom])
    }
    
    func center(to: UIView, horizontalAdjustment: CGFloat = 0, verticalAdjustment: CGFloat = 0) {
        disableTranslation()
        UIView.align(parent: to, child: self, attribute: .centerX, constant: horizontalAdjustment)
        UIView.align(parent: to, child: self, attribute: .centerY, constant: verticalAdjustment)
    }
    
    func bottom(to: UIView, verticalAdjustment: CGFloat = 0) {
        disableTranslation()
        UIView.align(parent: to, child: self, attribute: .centerX, constant: 0)
        UIView.align(parent: to, child: self, attribute: .bottom, constant: verticalAdjustment)
    }
    
    func sizeWithoutDisablingTranslation(width: CGFloat, height: CGFloat) {
        UIView.align(parent: self, child: nil, attribute: .width, constant: width)
        UIView.align(parent: self, child: nil, attribute: .height, constant: height)
    }
    
    private func disableTranslation() {
        let constraints = self.constraints
        for c in constraints {
            self.removeConstraint(c)
        }
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private class func alignMultiple(parent: UIView, child: UIView?, attributes: [NSLayoutAttribute], constant: CGFloat = 0) {
        for attr in attributes {
            align(parent: parent, child: child, attribute: attr, constant: constant)
        }
    }
    
    @discardableResult
    private class func align(parent: UIView, child: UIView?, attribute: NSLayoutAttribute, constant: CGFloat = 0) -> NSLayoutConstraint {
        let c = NSLayoutConstraint(item: parent,
                                   attribute: attribute,
                                   relatedBy: .equal,
                                   toItem: child,
                                   attribute: (child == nil) ? .notAnAttribute : attribute,
                                   multiplier: 1,
                                   constant: constant)
        parent.addConstraint(c)
        return c
    }
}

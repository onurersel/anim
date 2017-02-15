//
//  AnimatorType.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-14.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import UIKit

public extension anim {

    /// Describes which animator to be used.
    public enum AnimatorType {

        /// Propery animator uses the new animation controller, introduces with iOS 10.
        case propertyAnimator
        /// View animator uses the old `UIView.animate` function.
        case viewAnimator

        /// Returns animator instance for the type. Fall back to `ViewAnimator` if the device is 
        /// below iOS 10.
        internal var availableInstance: Animator {
            if #available(iOS 10.0, *), self == .propertyAnimator {
                return PropertyAnimator()
            }

            return ViewAnimator()
        }
    }

}

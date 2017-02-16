//
//  Constraint.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

internal extension anim {

    /// Constraint animation information is stored with this value, instead of a single `Closure`.
    internal struct ConstraintLayout {
        /// Animation block.
        internal var closure: Closure
        /// Top parent of constraints to be animated.
        internal var parent: View

        /// Calls update function for layouts on different platforms.
        internal func update() {
            #if os(iOS)
            parent.layoutIfNeeded()
            #elseif os(OSX)
            parent.layoutSubtreeIfNeeded()
            #endif
        }
    }

}

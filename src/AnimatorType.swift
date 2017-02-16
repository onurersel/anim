/**
 *  anim
 *
 *  Copyright (c) 2017 Onur Ersel. Licensed under the MIT license, as follows:
 *
 *  Permission is hereby granted, free of charge, to any person obtaining a copy
 *  of this software and associated documentation files (the "Software"), to deal
 *  in the Software without restriction, including without limitation the rights
 *  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 *  copies of the Software, and to permit persons to whom the Software is
 *  furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included in all
 *  copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 *  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 *  SOFTWARE.
 */

import Foundation

public extension anim {

    /// Defines which animator will be used in animation.
    public enum AnimatorType {

        /// Uses `UIViewPropertyAnimator`, only available on iOS 10.
        case propertyAnimator
        /// Uses `UIView.animate`. Available on iOS versions below 10.
        case viewAnimator
        /// Uses `NSAnimationContext`. Only available on macOS.
        case macAnimator

        /// Returns default animator for different platforms.
        static public var `default`: AnimatorType {
            #if os(iOS)
                return .propertyAnimator
            #elseif os(OSX)
                return .macAnimator
            #endif
        }

        /// Returns an instance of animator.
        public var instance: Animator {
            #if os(iOS)
            if #available(iOS 10.0, *), self == .propertyAnimator {
                return PropertyAnimator()
            } else {
                return ViewAnimator()
            }
            #elseif os(OSX)
            return MacAnimator()
            #endif
        }

    }

}

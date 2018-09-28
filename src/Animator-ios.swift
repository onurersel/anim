//
//  Animator-ios.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-16.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

#if os(iOS) || os(tvOS)
import UIKit

/// `PropetyAnimator` uses new `UIViewPropertyAnimator` which's introduced with iOS 10.
@available (iOS 10.0, *)
@available (tvOS 10.0, *)
internal class PropertyAnimator: Animator {

    /// Storing property animator, so it can be used for stopping animations later.
    private var propertyAnimator: UIViewPropertyAnimator?
    /// Completion block.
    private var completion: animClosure?

    /// Starts animation. Refer to protocol description for more information.
    internal func startAnimation(animationClosure: @escaping animClosure,
                                 completion: @escaping animClosure,
                                 settings: animSettings) {

        propertyAnimator = UIViewPropertyAnimator(duration: settings.duration,
                                                  controlPoint1: settings.ease.point1,
                                                  controlPoint2: settings.ease.point2,
                                                  animations: animationClosure)
        propertyAnimator!.addCompletion(completeAnimation)
        self.completion = completion
        propertyAnimator!.isUserInteractionEnabled = settings.isUserInteractionsEnabled
        propertyAnimator!.startAnimation()
    }

    /// Stops animation. Refer to protocol description for more information.
    internal func stopAnimation() {
        propertyAnimator?.stopAnimation(true)
        cleanup()
    }

    /// Called when animation is completed.
    private func completeAnimation(position: UIViewAnimatingPosition) {
        completion?()
        cleanup()
    }

    /// Cleans up stored properties.
    private func cleanup() {
        propertyAnimator = nil
        completion = nil
    }
}

/// `ViewAnimator` uses old `UIView.animate`. It supports old versions to iOS 8.
///
/// `UIView.animate` doesn't support stopping animations without accessing layers of
/// animated properties, so some shady stuff are happening here 😏.
///
/// In short, `startAnimation` method [swizzles](http://nshipster.com/method-swizzling/) `CALayer.add`.
/// New method lets animator store layer and key information for the newly created animation.
/// After animations are created, it swizzles back to original `CALayer.add` method.
/// When `stopAnimation` function is called, it uses the stored information to stop animations.
@available (iOS, deprecated: 10.0, message: "`ViewAnimator` is deprecated at iOS 10. Use `PropertyAnimator` instead.")
internal class ViewAnimator: Animator {

    /// `AnimationLayer` value type stores added animation information, in order to
    ///  stop them if requested.
    internal struct AnimatingLayer {
        internal var layer: CALayer
        internal var key: String
    }

    /// References to the methods which will be swizzled.
    static private let methodOriginal = class_getInstanceMethod(CALayer.self, #selector(CALayer.add))
    static private let methodSwizzled = class_getInstanceMethod(CALayer.self, #selector(CALayer.anim_add))

    /// Static reference to the active `ViewAnimator`.
    ///
    /// It's only stored while in scope of `startAnimation`. `CALayer.anim_add` uses this reference
    /// to send animation information to `ViewAnimator`.
    static internal var activeInstance: ViewAnimator?

    /// Custom timing function which will be passed to `CALayer.anim_add`.
    static internal var timingFunction: CAMediaTimingFunction?

    /// All information regarding to animations created by this `ViewAnimation` is stored here.
    private var animatingLayers: [AnimatingLayer]? = []

    /// Starts animation. Refer to protocol description for more information.
    internal func startAnimation(animationClosure: @escaping  animClosure,
                                 completion: @escaping animClosure,
                                 settings: animSettings) {

        // Creating raw value for `UIViewAnimationOptions`.
        var optionsRaw: UInt = 0
        if settings.isUserInteractionsEnabled {
            optionsRaw += UIView.AnimationOptions.allowUserInteraction.rawValue
        }

        // Starting to swizzle.
        method_exchangeImplementations(ViewAnimator.methodOriginal!, ViewAnimator.methodSwizzled!)

        // Storing this instance so `CALayer.anim_add` can use it.
        ViewAnimator.activeInstance = self
        // Also storing timing function, so `CALayer.anim_add` can access it.
        ViewAnimator.timingFunction = settings.ease.caMediaTimingFunction

        // Animating...
        UIView.animate(withDuration: settings.duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: optionsRaw),
                       animations: animationClosure,
                       completion: { _ in
                        completion()
                        self.cleanup()
        })

        // Clearing static references right after animations are being created.
        ViewAnimator.activeInstance = nil
        ViewAnimator.timingFunction = nil

        // Swizzling back.
        method_exchangeImplementations(ViewAnimator.methodSwizzled!, ViewAnimator.methodOriginal!)
    }

    /// Stops animation. Refer to protocol description for more information.
    internal func stopAnimation() {
        animatingLayers?.forEach { animatingLayer in
            animatingLayer.layer.removeAnimation(forKey: animatingLayer.key)
        }
        cleanup()
    }

    /// Cleans stored animation information.
    private func cleanup() {
        animatingLayers?.removeAll()
        animatingLayers = nil
    }

    /// `CALayer.anim_add` uses this function to send animation information to `ViewAnimator`.
    ///
    /// - Parameters:
    ///   - layer: Layer that animation is added on.
    ///   - key: Animation key.
    internal class func addLayerToAnimator(_ layer: CALayer, _ key: String) {
        ViewAnimator.activeInstance?.animatingLayers?.append(AnimatingLayer(layer: layer, key: key))
    }
}

@available (iOS, deprecated: 10.0)
fileprivate extension CALayer {
    /// Used for interrupting `CALayer.add` method. Sets custom timing function for easing,
    /// and sends back animation information, so `ViewAnimator` can stop the animation.
    @objc
    func anim_add(_ animation: CAAnimation, forKey key: String?) {
        animation.timingFunction = ViewAnimator.timingFunction
        ViewAnimator.addLayerToAnimator(self, key!)
        self.anim_add(animation, forKey: key)
    }
}
#endif

//
//  anim.swift
//  anim
//
//  Created by Onur Ersel on 15/01/16.
//  Copyright © 2016 Onur Ersel. All rights reserved.
//

import UIKit

public enum Ease {
    case linear
    case sineOut, sineIn, sineInOut
    case quadOut, quadIn, quadInOut
    case quintOut, quintIn, quintInOut
    case cubicOut, cubicIn, cubicInOut
    case quartOut, quartIn, quartInOut
    case expoOut, expoIn, expoInOut
    case circOut, circIn, circInOut
    case backOut, backIn, backInOut
    
    /*
    control point values are from http://easings.net/
    */
    func mediaTiming () -> CAMediaTimingFunction? {
        
        switch self {

        case .linear:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            

        case .sineIn:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        case .sineOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        case .sineInOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            
        case .quadIn:
            return CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)
        case .quadOut:
            return CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)
        case .quadInOut:
            return CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)
            
            
        case .cubicIn:
            return CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)
        case .cubicOut:
            return CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)
        case .cubicInOut:
            return CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)
            
            
        case .quartIn:
            return CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)
        case .quartOut:
            return CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
        case .quartInOut:
            return CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)
            
            
        case .quintIn:
            return CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)
        case .quintOut:
            return CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        case .quintInOut:
            return CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)
            
            
        case .expoIn:
            return CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)
        case .expoOut:
            return CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
        case .expoInOut:
            return CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)
            
            
        case .circIn:
            return CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)
        case .circOut:
            return CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
        case .circInOut:
            return CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)
            
            
        case .backIn:
            return CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)
        case .backOut:
            return CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
        case .backInOut:
            return CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)
            
        }
    }
}




/*****************************
 */
 //MARK: scope
 /*
 *****************************/
open class OEAnim {
    public typealias animClosure = ( ()->Void )
    public typealias compClosure = ( (_ finished : Bool)->Void )
    public typealias easingFunctionClosure = ( (_ p : Double)->Double )
    
    open static var passedAnimEase : Ease?
}



/*****************************
 */
 //MARK: animation
 /*
 *****************************/


public func anim (duration animDuration: TimeInterval, easing : Ease, animation : @escaping OEAnim.animClosure) {
    anim(duration: animDuration, delay: 0, easing: easing, options: UIViewAnimationOptions.curveLinear, animation: animation, completion: nil)
}
public func anim (duration animDuration: TimeInterval, easing : Ease, animation : @escaping OEAnim.animClosure, completion : OEAnim.compClosure?) {
    anim(duration: animDuration, delay: 0, easing: easing, options: UIViewAnimationOptions.curveLinear, animation: animation, completion: completion)
}
public func anim (duration animDuration: TimeInterval, delay : TimeInterval, easing : Ease, animation : @escaping OEAnim.animClosure) {
    anim(duration: animDuration, delay: delay, easing: easing, options: UIViewAnimationOptions.curveLinear, animation: animation, completion: nil)
}
public func anim (duration animDuration: TimeInterval, delay : TimeInterval, easing : Ease, animation : @escaping OEAnim.animClosure, completion : OEAnim.compClosure?) {
    anim(duration: animDuration, delay: delay, easing: easing, options: UIViewAnimationOptions.curveLinear, animation: animation, completion: completion)
}


public func anim (duration animDuration: TimeInterval, delay : TimeInterval, easing : Ease, options:UIViewAnimationOptions, animation : @escaping OEAnim.animClosure, completion : OEAnim.compClosure?) {
    
    
    //swizzle
    struct Static {
        static var token : Int = 0
    }
    
    let globalSwizzle : () = {
        let methodOriginal = class_getInstanceMethod(CALayer.self, #selector(CALayer.add(_:forKey:)))
        let methodSwizzled = class_getInstanceMethod(CALayer.self, #selector(CALayer.anim_addAnimation(_:forKey:)))
        method_exchangeImplementations(methodOriginal, methodSwizzled)
    }()
    _ = globalSwizzle
    
    //store easing
    OEAnim.passedAnimEase = easing

    //animate with block
    UIView.animate(withDuration: animDuration, delay: delay, options: options, animations: animation, completion: completion)
    
}


/*****************************
 */
 //MARK: extension
 /*
 *****************************/


extension CALayer {
    
    func anim_addAnimation ( _ animation : CAAnimation, forKey: String ) {
        
        if let pte = OEAnim.passedAnimEase {
            animation.timingFunction = pte.mediaTiming()
            self.anim_addAnimation(animation, forKey: forKey)
        }
        
    }
    
}

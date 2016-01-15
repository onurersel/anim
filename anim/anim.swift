//
//  anim.swift
//  anim
//
//  Created by Onur Ersel on 15/01/16.
//  Copyright © 2016 Onur Ersel. All rights reserved.
//

import UIKit


typealias animClosure = ( ()->Void )
typealias compClosure = ( (finished : Bool)->Void )
typealias easingFunctionClosure = ( (p : CGFloat)->CGFloat )

let keyframeCount : CGFloat = 60.0
var _passedAnimEase : AnimEase?


enum AnimEase {
    case Linear
    case SineOut, SineIn, SineInOut
    case QuadOut, QuadIn, QuadInOut
    case QuintOut, QuintIn, QuintInOut
    case CubicOut, CubicIn, CubicInOut
    case QuartOut, QuartIn, QuartInOut
    case ExpoOut, ExpoIn, ExpoInOut
    case CircOut, CircIn, CircInOut
    case BackOut, BackIn, BackInOut
    
    
    /*
    easing values are from http://easings.net/
    */
    func definition () -> CAMediaTimingFunction {
        
        switch self {

        case .Linear:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            

        case .SineIn:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        case .SineOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        case .SineInOut:
            return CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            
            
        case .QuadIn:
            return CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)
        case .QuadOut:
            return CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)
        case .QuadInOut:
            return CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)
            
            
        case .CubicIn:
            return CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)
        case .CubicOut:
            return CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)
        case .CubicInOut:
            return CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)
            
            
        case .QuartIn:
            return CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)
        case .QuartOut:
            return CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
        case .QuartInOut:
            return CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)
            
            
        case .QuintIn:
            return CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)
        case .QuintOut:
            return CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
        case .QuintInOut:
            return CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)
            
            
        case .ExpoIn:
            return CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)
        case .ExpoOut:
            return CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
        case .ExpoInOut:
            return CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)
            
            
        case .CircIn:
            return CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)
        case .CircOut:
            return CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
        case .CircInOut:
            return CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)
            
            
        case .BackIn:
            return CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)
        case .BackOut:
            return CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
        case .BackInOut:
            return CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)
        
        }
    }
    
}


func EaseFuncElasticOut (p : CGFloat)->CGFloat {
    return sin(-13 * CGFloat(M_PI_2) * (p + 1)) * pow(2, -10 * p) + 1
}


func GenerateFloatKeyframesWithFunction (from : CGFloat, to : CGFloat, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = CGFloat(i)/keyframeCount
        let value = from + easingFunc(p: t) * (to-from)
        values.append(value)
    }
    
    return values
}
func GenerateSizeKeyframesWithFunction (from : CGSize, to : CGSize, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = CGFloat(i)/keyframeCount
        let valueWidth = from.width + easingFunc(p: t) * (to.width-from.width)
        let valueHeight = from.height + easingFunc(p: t) * (to.height-from.height)
        values.append(NSValue(CGSize:CGSize(width: valueWidth, height: valueHeight)))
    }
    
    return values
}




func anim (duration animDuration: NSTimeInterval, easing : AnimEase, animation : animClosure) {
    anim(duration: animDuration, delay: 0, easing: easing, options: UIViewAnimationOptions.CurveLinear, animation: animation, completion: nil)
}
func anim (duration animDuration: NSTimeInterval, delay : NSTimeInterval, easing : AnimEase, animation : animClosure) {
    anim(duration: animDuration, delay: delay, easing: easing, options: UIViewAnimationOptions.CurveLinear, animation: animation, completion: nil)
}


func anim (duration animDuration: NSTimeInterval, delay : NSTimeInterval, easing : AnimEase, options:UIViewAnimationOptions, animation : animClosure, completion : compClosure?) {
    
    
    //swizzle
    struct Static {
        static var token : dispatch_once_t = 0
    }
    
    dispatch_once(&Static.token) {
        let methodOriginal = class_getInstanceMethod(CALayer.self, "addAnimation:forKey:")
        let methodSwizzled = class_getInstanceMethod(CALayer.self, "anim_addAnimation:forKey:")
        method_exchangeImplementations(methodOriginal, methodSwizzled)
    }
    
    //save function
    _passedAnimEase = easing

    //animate with block
    UIView.animateWithDuration(animDuration, delay: delay, options: options, animations: animation, completion: completion)
    
}


extension CALayer {
    
    func anim_addAnimation ( animation : CAAnimation, forKey: String ) {
        if let pte = _passedAnimEase, ba = animation as? CABasicAnimation {
            animation.timingFunction = pte.definition()
        }
        
        self.anim_addAnimation(animation, forKey: forKey)
    }
    
}
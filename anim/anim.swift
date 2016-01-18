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
typealias easingFunctionClosure = ( (p : Double)->Double )

let keyframeCount : Double = 60.0
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
    
    case ElasticOut, ElasticIn, ElasticInOut
    case BounceOut, BounceIn, BounceInOut
    
    /*
    easing values are from http://easings.net/
    */
    func mediaTiming () -> CAMediaTimingFunction? {
        
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
            
        default:
            return nil
            
        }
    }
    
    func easingFunction () -> easingFunctionClosure? {
        switch self {
        case .ElasticOut:
            return EaseFuncElasticOut
            
        default:
            return nil
        }
    }
    
    
    func isKeyframeAnimation() -> Bool {
        switch self {
        case .ElasticOut:
            return true
        default:
            return false
        }
    }
}





/*****************************
 */
 //MARK: easing functions
 /*
 *****************************/



func EaseFuncElasticOut (p : Double)->Double {
    return sin(-13 * M_PI_2 * (p + 1)) * pow(2, -10 * p) + 1
}
func EaseFuncElasticIn (p : Double)->Double {
    return sin(13 * M_PI_2 * p) * pow(2, 10 * (p - 1))
}
func EaseFuncElasticInOut (p : Double)->Double {
    if p < 0.5
    {
        return 0.5 * sin(13 * M_PI_2 * (2 * p)) * pow(2, 10 * ((2 * p) - 1));
    }
    else
    {
        return 0.5 * (sin(-13 * M_PI_2 * ((2 * p - 1) + 1)) * pow(2, -10 * (2 * p - 1)) + 2);
    }
}
func EaseFuncBounceOut (p : Double)->Double {
    if p < 4/11.0
    {
        return (121 * p * p)/16.0;
    }
    else if(p < 8/11.0)
    {
        return (363/40.0 * p * p) - (99/10.0 * p) + 17/5.0;
    }
    else if(p < 9/10.0)
    {
        return (4356/361.0 * p * p) - (35442/1805.0 * p) + 16061/1805.0;
    }
    else
    {
        return (54/5.0 * p * p) - (513/25.0 * p) + 268/25.0;
    }
}
func EaseFuncBounceIn (p : Double)->Double {
    return 1 - EaseFuncBounceOut(1 - p)
}
func EaseFuncBounceInOut (p : Double)->Double {
    if(p < 0.5)
    {
        return 0.5 * EaseFuncBounceIn(p*2);
    }
    else
    {
        return 0.5 * EaseFuncBounceOut(p * 2 - 1) + 0.5;
    }
}








/*****************************
*/
//MARK: keyframes
/*
*****************************/


func GenerateKeyframesWithFunction (from : Double, to : Double, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = Double(i)/keyframeCount
        let value = from + easingFunc(p: t) * (to-from)
        values.append(value)
    }
    
    return values
}

func GenerateKeyframesWithFunction (from : CGSize, to : CGSize, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = Double(i)/keyframeCount
        let easedT = easingFunc(p: t)
        let valueWidth = Double(from.width) + easedT * Double(to.width-from.width)
        let valueHeight = Double(from.height) + easedT * Double(to.height-from.height)
        values.append(NSValue(CGSize:CGSize(width: valueWidth, height: valueHeight)))
    }
    
    return values
}
func GenerateKeyframesWithFunction (from : CGPoint, to : CGPoint, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = Double(i)/keyframeCount
        let easedT = easingFunc(p: t)
        let valueX = Double(from.x) + easedT * Double(to.x-from.x)
        let valueY = Double(from.y) + easedT * Double(to.y-from.y)
        values.append(NSValue(CGPoint:CGPoint(x: valueX, y: valueY)))
    }
    
    return values
}
func GenerateKeyframesWithFunction (from : CGRect, to : CGRect, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = Double(i)/keyframeCount
        let easedT = easingFunc(p: t)
        let valueX = Double(from.origin.x) + easedT * Double(to.origin.x-from.origin.x)
        let valueY = Double(from.origin.y) + easedT * Double(to.origin.y-from.origin.y)
        let valueWidth = Double(from.size.width) + easedT * Double(to.size.width-from.size.width)
        let valueHeight = Double(from.size.height) + easedT * Double(to.size.height-from.size.height)
        values.append(NSValue(CGRect:CGRect(x: valueX, y: valueY, width: valueWidth, height: valueHeight)))
    }
    
    return values
}
func GenerateKeyframesWithFunction (from : CATransform3D, to : CATransform3D, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    for i in 0..<60 {
        let t = Double(i)/keyframeCount
        let easedT = CGFloat(easingFunc(p: t))
        var value = CATransform3D()
        value.m11 = from.m11 + easedT * (to.m11 - from.m11)
        value.m12 = from.m12 + easedT * (to.m12 - from.m12)
        value.m13 = from.m13 + easedT * (to.m13 - from.m13)
        value.m14 = from.m14 + easedT * (to.m14 - from.m14)
        
        value.m21 = from.m21 + easedT * (to.m21 - from.m21)
        value.m22 = from.m22 + easedT * (to.m22 - from.m22)
        value.m23 = from.m23 + easedT * (to.m23 - from.m23)
        value.m24 = from.m24 + easedT * (to.m24 - from.m24)
        
        value.m31 = from.m31 + easedT * (to.m31 - from.m31)
        value.m32 = from.m32 + easedT * (to.m32 - from.m32)
        value.m33 = from.m33 + easedT * (to.m33 - from.m33)
        value.m34 = from.m34 + easedT * (to.m34 - from.m34)
        
        value.m41 = from.m41 + easedT * (to.m41 - from.m41)
        value.m42 = from.m42 + easedT * (to.m42 - from.m42)
        value.m43 = from.m43 + easedT * (to.m43 - from.m43)
        value.m44 = from.m44 + easedT * (to.m44 - from.m44)
        
        values.append(NSValue(CATransform3D: value))
    }
    
    return values
}
func GenerateKeyframesWithFunction (from : CGColorRef, to : CGColorRef, easingFunc : easingFunctionClosure) -> [AnyObject] {
    var values = [AnyObject]()
    
    let colorSpace = CGColorGetColorSpace(to)
    let numberOfComponents = CGColorGetNumberOfComponents(to)
    let fromComponents = CGColorGetComponents(from)
    let toComponents = CGColorGetComponents(to)
    var components = [CGFloat]()
    
    for i in 0..<60 {
        let t = Double(i)/keyframeCount
        let easedT = CGFloat(easingFunc(p: t))
        for var c = 0; c < numberOfComponents; ++c {
            print(fromComponents[c] + easedT * (toComponents[c] - fromComponents[c]))
            components.append(fromComponents[c] + easedT * (toComponents[c] - fromComponents[c]))
        }
        
        let value = CGColorCreate(colorSpace, components)!
        
        values.append(value)
    }
    
    return values
}






/*****************************
 */
 //MARK: prepare keyframes
 /*
 *****************************/



func prepareKeyframes (animation : CABasicAnimation, from : AnyObject, to : AnyObject, ease : AnimEase) -> [AnyObject]? {
    
    let easingFunc = ease.easingFunction()!
    var values : [AnyObject]? = nil
    
    
    if from is CGColorRef {
        values = GenerateKeyframesWithFunction(from as! CGColorRef, to: to as! CGColorRef, easingFunc: easingFunc)
    } else {
        switch from.objCType {
        case NSNumber().objCType:
            #if CGFLOAT_IS_DOUBLE
                values = GenerateKeyframesWithFunction(from.doubleValue, to: to.doubleValue, easingFunc: easingFunc)
            #else
                values = GenerateKeyframesWithFunction(Double(from.floatValue), to: Double(to.floatValue), easingFunc: easingFunc)
            #endif
            
            
        case NSValue(CGSize: CGSize()).objCType:
            values = GenerateKeyframesWithFunction(from.CGSizeValue(), to: to.CGSizeValue(), easingFunc: easingFunc)
            
        case NSValue(CGPoint: CGPoint()).objCType:
            values = GenerateKeyframesWithFunction(from.CGPointValue, to: to.CGPointValue, easingFunc: easingFunc)
            
        case NSValue(CGRect: CGRect()).objCType:
            values = GenerateKeyframesWithFunction(from.CGRectValue, to: to.CGRectValue, easingFunc: easingFunc)
            
        case NSValue(CATransform3D: CATransform3D()).objCType:
            values = GenerateKeyframesWithFunction(from.CATransform3DValue, to: to.CATransform3DValue, easingFunc: easingFunc)
            
        default:
            break
        }
    }
    
    return values

}





/*****************************
 */
 //MARK: animation
 /*
 *****************************/


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
    
    //store easing
    _passedAnimEase = easing

    //animate with block
    UIView.animateWithDuration(animDuration, delay: delay, options: options, animations: animation, completion: completion)
    
}


extension CALayer {
    
    func anim_addAnimation ( animation : CAAnimation, forKey: String ) {
        
        var anim : CAAnimation?
        
        if let pte = _passedAnimEase, ba = animation as? CABasicAnimation {
            animation.timingFunction = pte.mediaTiming()
            
            if pte.isKeyframeAnimation() {
                
                let currentValue = self.valueForKey(ba.keyPath!)
                let from = (ba.fromValue ?? currentValue)!
                let to = (ba.toValue ?? currentValue)!
                
                let kAnim = CAKeyframeAnimation(keyPath: ba.keyPath)
                kAnim.values = prepareKeyframes(ba, from: from, to: to, ease: pte)
                kAnim.duration = ba.duration
                kAnim.beginTime = ba.beginTime + self.convertTime(CACurrentMediaTime(), fromLayer: nil)
                kAnim.speed = ba.speed
                kAnim.timeOffset = ba.timeOffset
                kAnim.repeatCount = ba.repeatCount
                kAnim.repeatDuration = ba.repeatDuration
                kAnim.autoreverses = ba.autoreverses
                kAnim.fillMode = ba.fillMode
                kAnim.delegate = ba.delegate
                kAnim.additive = ba.additive
                kAnim.cumulative = ba.cumulative
                kAnim.removedOnCompletion = ba.removedOnCompletion
                
                anim = kAnim
                
            } else {
                anim = ba
            }
            
        }
        
        if let a = anim {
            self.anim_addAnimation(a, forKey: forKey)
        }
        
    }
    
}
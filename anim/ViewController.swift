//
//  ViewController.swift
//  anim
//
//  Created by Onur Ersel on 15/01/16.
//  Copyright © 2016 Onur Ersel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var v : UIView?
    
    var c1 : NSLayoutConstraint?
    var c2 : NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        v = UIView();
        self.view.addSubview(v!)
        v!.backgroundColor = UIColor.redColor()
        
        c1 = NSLayoutConstraint(item: v!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 100)
        self.view.addConstraint(c1!)
        c2 = NSLayoutConstraint(item: v!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 200)
        self.view.addConstraint(c2!)
        
        var c = NSLayoutConstraint(item: v!, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 50)
        self.view.addConstraint(c)
        c = NSLayoutConstraint(item: v!, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1, constant: 50)
        self.view.addConstraint(c)
        
        
        //NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "test", userInfo: nil, repeats: false)
        
        
    }

    @objc func test () {
        
        
        self.view.removeConstraint(c1!)
        self.view.removeConstraint(c2!)
        
        c1 = NSLayoutConstraint(item: v!, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 400)
        self.view.addConstraint(c1!)
        c2 = NSLayoutConstraint(item: v!, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 250)
        self.view.addConstraint(c2!)
        
        
        anim(duration: 1, easing: AnimEase.QuintInOut, animation: self.view.layoutIfNeeded)
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


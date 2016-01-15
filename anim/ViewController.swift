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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        v = UIView();
        self.view.addSubview(v!)
        v!.backgroundColor = UIColor.redColor()
        v!.frame = CGRect(x: 20, y: 30, width: 50, height: 100)
        
        
        NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "test", userInfo: nil, repeats: false)
        
        
    }

    @objc func test () {
        
        
        anim(duration: 1, delay: 2, easing: AnimEase.BackInOut, options: UIViewAnimationOptions.CurveLinear, animation: {
            
            self.v!.frame = CGRect(x: 200, y: 200, width: 100, height: 50)
            
            }) { finished in
                
                print("finished")
                
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


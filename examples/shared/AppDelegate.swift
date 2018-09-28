//
//  AppDelegate.swift
//  examples
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var roundCornerWindow: RoundCornerWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        roundCornerWindow = RoundCornerWindow.create()
        
        return true
    }
}


class RoundCornerWindow: UIWindow {
    
    class func create() -> RoundCornerWindow {
        let window = RoundCornerWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()

        #if os(iOS)
        window.windowLevel = UIWindow.Level.statusBar + 1
        #else
        window.windowLevel = UIWindow.Level(rawValue: 2)
        #endif

        window.isUserInteractionEnabled = false
        window.backgroundColor = UIColor.clear
        window.isHidden = false
        
        if let parent = window.rootViewController?.view {
            let borderView = UIImageView(image: #imageLiteral(resourceName: "splash_background"))
            parent.addSubview(borderView)
            borderView.snapEdges(to: parent)
        }
        
        return window
    }
    
}

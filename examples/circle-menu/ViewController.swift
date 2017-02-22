//
//  ViewController.swift
//  example-circle-menu
//
//  Created by Onur Ersel on 2017-02-21.
//  Copyright © 2017 Onur Ersel. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundView = UIImageView(image: #imageLiteral(resourceName: "background"))
        self.view.addSubview(backgroundView)
        
        backgroundView.snapEdges(to: self.view)
    }

}


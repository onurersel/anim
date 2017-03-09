//
//  ProfileDetailViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-09.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

class ProfileDetailViewController: UIViewController {
    
    var backButtonView: BackButton!
    
    private var headerView: UIView!
    private var headerHeightConstraint: NSLayoutConstraint!
    private var backButtonConstraints: [NSLayoutConstraint]!
    
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        // header
        headerView = UIView()
        headerView.backgroundColor = Color.lightGray
        self.view.addSubview(headerView)
        UIView.alignMultiple(view: headerView, to: self.view, attributes: [.left, .top, .right])
        //UIView.align(view: headerView, to: nil, attribute: .height, constant: 173)
        headerHeightConstraint = UIView.align(view: headerView, to: nil, attribute: .height, constant: 71)
        
        // back button
        backButtonView = BackButton.create()
        headerView.addSubview(backButtonView)
        backButtonConstraints = backButtonView.snapEdges(to: headerView)
        
        // body container
        let bodyContainerView = UIScrollView()
        bodyContainerView.contentInset = UIEdgeInsetsMake(67, 0, 42, 0)
        self.view.addSubview(bodyContainerView)
        UIView.alignMultiple(view: bodyContainerView, to: self.view, attributes: [.left, .bottom, .right])
        self.view.addConstraint(
            NSLayoutConstraint(item: bodyContainerView, attribute: .top, relatedBy: .equal, toItem: headerView, attribute: .bottom, multiplier: 1, constant: 0)
        )
        
        // text
        let textLabelView = UILabel()
        textLabelView.textColor = Color.lightGray
        textLabelView.numberOfLines = 12
        textLabelView.font = UIFont(name: Font.nameBlokk, size: 18)
        textLabelView.contentMode = .top
        textLabelView.translatesAutoresizingMaskIntoConstraints = false
        bodyContainerView.addSubview(textLabelView)
        
        UIView.align(view: textLabelView, to: bodyContainerView, attribute: .top, constant: 0)
        UIView.align(view: textLabelView, to: self.view, attribute: .left, constant: 34)
        UIView.align(view: textLabelView, to: self.view, attribute: .right, constant: -34)
        UIView.align(view: textLabelView, to: nil, attribute: .height, constant: 363)
        
        textLabelView.attributedText = Dummy.text(46).attributedBlock
        
        // image
        let imageView = UIView()
        imageView.backgroundColor = Color.lightGray
        bodyContainerView.addSubview(imageView)
        
        UIView.align(view: imageView, to: self.view, attribute: .left, constant: 34)
        UIView.align(view: imageView, to: self.view, attribute: .right, constant: -34)
        UIView.align(view: imageView, to: nil, attribute: .height, constant: 173)
        
        bodyContainerView.addConstraints([
            NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: textLabelView, attribute: .bottom, multiplier: 1, constant: 27),
            NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: bodyContainerView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        backButtonView.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        backButtonView.removeTarget(self, action: #selector(self.backAction), for: .touchUpInside)
    }
    
    // MARK: Animations
    
    func startHeaderInAnimation() {
        
        anim(constraintParent: self.view) { (settings) -> animClosure in
            settings.ease = .easeInOutQuint
            return {
                self.headerHeightConstraint.constant = 173
                
                self.headerView.removeConstraints(self.backButtonConstraints)
                UIView.alignMultiple(view: self.backButtonView, to: self.headerView, attributes: [.left, .top], constant: 26)
                self.backButtonView.size(width: 38, height: 38)
            }
        }
        
        
        
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInOutQuint
            return {
                self.backButtonView.layer.cornerRadius = 20
                self.backButtonView.backgroundColor = UIColor.white
                self.headerView.backgroundColor = Color.red
            }
        }
    }
    
    // MARK: Handlers
    
    @objc
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
}


class BackButton: UIButton {
    
    var arrowImageView: UIImageView!
    
    class func create() -> BackButton {
        let view = BackButton()
        
        // background
        view.backgroundColor = Color.lightGray
        
        // arrow
        view.arrowImageView = UIImageView(image: #imageLiteral(resourceName: "back_arrow"))
        view.addSubview(view.arrowImageView)
        view.arrowImageView.center(to: view)
        
        return view
    }
}

//
//  ProfileViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-09.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim

// MARK: - ViewController

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var tableView: UITableView!
    private var lastCellDisplayTimeInterval: TimeInterval = Date.timeIntervalSinceReferenceDate
    
    var selectedProfileCell: ProfileCell? {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            return tableView.cellForRow(at: selectedIndexPath) as? ProfileCell
        }
        return nil
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 179
        tableView.separatorColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        self.tableView.setContentOffset(CGPoint(x:0, y:-91), animated: false)
        tableView.snapEdges(to: self.view)
        
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedProfileCell?.setSelected(false, animated: false)
    }
    
    
    // MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = "profile_cell"
        let cell = (tableView.dequeueReusableCell(withIdentifier: cellName) ?? ProfileCell(style: .default, reuseIdentifier: cellName))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let profileCell = cell as? ProfileCell {
            display(cell: profileCell)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(ProfileDetailViewController(), animated: true)
    }
    
    // MARK: Cell Animation
    private func display(cell profileCell: ProfileCell) {
        
        let now = Date.timeIntervalSinceReferenceDate
        let delay = max(0, 0.1 - (now - lastCellDisplayTimeInterval))
        
        profileCell.positionOutState()
        if delay == 0 {
            profileCell.positionInStateWithAnimation()
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(delay*1000))) {
                profileCell.positionInStateWithAnimation()
            }
        }
        
        lastCellDisplayTimeInterval = now + delay
    }
}


// MARK: - Cell

class ProfileCell: UITableViewCell {
    
    var profilePictureView: UIView!
    private var inConstraint: NSLayoutConstraint!
    private var outConstraint: NSLayoutConstraint!
    private var profileBoxView: UIButton!
    private var textContainerView: UIView!
    private var animations = [anim]()
    private var profilePictureConstraints = [NSLayoutConstraint]()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        // container
        let containerView = UIView()
        contentView.addSubview(containerView)
        UIView.align(view: containerView, to: nil, attribute: .height, constant: 157)
        UIView.align(view: containerView, to: contentView, attribute: .top, constant: 13)
        UIView.align(view: containerView, to: contentView, attribute: .left, constant: 26)
        UIView.align(view: containerView, to: contentView, attribute: .right, constant: -26)
        
        containerView.isUserInteractionEnabled = false
        
        // profile box
        profileBoxView = UIButton()
        profileBoxView.backgroundColor = Color.lightGray
        containerView.addSubview(profileBoxView)
        
        UIView.alignMultiple(view: profileBoxView, to: containerView, attributes: [.width, .height, .top])
        inConstraint = NSLayoutConstraint(item: profileBoxView, attribute: .left,
                                          relatedBy: .equal,
                                          toItem: containerView, attribute: .left,
                                          multiplier: 1, constant: 0)
        containerView.addConstraint(inConstraint)
        outConstraint = NSLayoutConstraint(item: profileBoxView, attribute: .right,
                                           relatedBy: .equal,
                                           toItem: contentView, attribute: .left,
                                           multiplier: 1, constant: 0)
        outConstraint.priority = 999
        contentView.addConstraint(outConstraint)
        
        // profile picture
        profilePictureView = UIView()
        profilePictureView.backgroundColor = Color.midGray
        profilePictureView.isUserInteractionEnabled = false
        profileBoxView.addSubview(profilePictureView)
        profilePictureView.layer.cornerRadius = 44
        profilePictureView.size(width: 87, height: 87)
        profilePictureConstraints.append( UIView.align(view: profilePictureView, to: profileBoxView, attribute: .left, constant: 28) )
        profilePictureConstraints.append( UIView.align(view: profilePictureView, to: profileBoxView, attribute: .centerY) )
        
        
        // text container
        textContainerView = UIView()
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.isUserInteractionEnabled = false
        profileBoxView.addSubview(textContainerView)
        
        profileBoxView.addConstraints([
            NSLayoutConstraint(item: textContainerView, attribute: .left, relatedBy: .equal, toItem: profilePictureView, attribute: .right, multiplier: 1, constant: 27),
            NSLayoutConstraint(item: textContainerView, attribute: .right, relatedBy: .equal, toItem: profileBoxView, attribute: .right, multiplier: 1, constant: -27),
            NSLayoutConstraint(item: textContainerView, attribute: .top, relatedBy: .equal, toItem: profileBoxView, attribute: .top, multiplier: 1, constant: 27),
            NSLayoutConstraint(item: textContainerView, attribute: .bottom, relatedBy: .equal, toItem: profileBoxView, attribute: .bottom, multiplier: 1, constant: -27)
            ])
        
        
        // title text
        let titleLabelView = UILabel()
        titleLabelView.font = UIFont(name: Font.nameBlokk, size: 36)
        titleLabelView.textColor = UIColor.white
        textContainerView.addSubview(titleLabelView)
        
        titleLabelView.text = Dummy.randomWord
        
        UIView.alignMultiple(view: titleLabelView, to: textContainerView, attributes: [.left, .top, .right])
        UIView.align(view: titleLabelView, to: nil, attribute: .height, constant: 30)
        
        // body text
        let bodyLabelView = UILabel()
        bodyLabelView.font = UIFont(name: Font.nameBlokk, size: 15)
        bodyLabelView.textColor = UIColor.white
        bodyLabelView.numberOfLines = 8
        textContainerView.addSubview(bodyLabelView)
        
        bodyLabelView.attributedText = Dummy.text.attributedBlock
        
        UIView.alignMultiple(view: bodyLabelView, to: textContainerView, attributes: [.left, .bottom, .right])
        textContainerView.addConstraint(
            NSLayoutConstraint(item: bodyLabelView, attribute: .top, relatedBy: .equal, toItem: titleLabelView, attribute: .bottom, multiplier: 1, constant: 5)
        )
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Position
    
    func positionInStateWithAnimation() {
        var a: anim!
        
        // position box
        a = anim(constraintParent: contentView) { (settings) -> animClosure in
            settings.duration = 0.4
            settings.delay = 0.1
            settings.ease = .easeOutQuint
            return {
                self.inConstraint.constant = 10
                self.inConstraint.isActive = true
            }
            }
            .then(constraintParent: contentView) { (settings) -> animClosure in
                settings.duration = 0.5
                settings.ease = .easeInOutSine
                return {
                    self.inConstraint.constant = 0
                }
        }
        animations.append(a)
        
        // fade in box
        profileBoxView.alpha = 0.4
        a = anim { (settings) -> (animClosure) in
            settings.duration = 0.4
            settings.delay = 0.2
            settings.ease = .easeOutQuint
            return {
                self.profileBoxView.alpha = 1
            }
        }
        animations.append(a)
        
        // profile picture fade
        profilePictureView.alpha = 0
        profilePictureView.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7)
        a = anim { (settings) -> (animClosure) in
            settings.delay = 0.2
            settings.duration = 0.8
            settings.ease = .easeOutBack
            return {
                self.profilePictureView.alpha = 1
                self.profilePictureView.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
        }
        animations.append(a)
        
        // text fade
        textContainerView.alpha = 0
        a = anim { (settings) -> (animClosure) in
            settings.duration = 0.5
            settings.delay = 0.3
            settings.ease = .easeOutQuint
            return {
                self.textContainerView.alpha = 1
            }
        }
        animations.append(a)
    }
    
    func positionOutState() {
        animations.forEach { (animation) in
            animation.stop()
        }
        animations.removeAll()
        
        inConstraint.isActive = false
        contentView.layoutIfNeeded()
    }
}

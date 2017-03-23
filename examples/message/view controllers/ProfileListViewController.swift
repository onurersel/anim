//
//  ProfileListViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-09.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


// MARK: - View Controller

class ProfileListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private var tableView: UITableView!
    private var lastCellDisplayTimeInterval: TimeInterval = Date.timeIntervalSinceReferenceDate

    var selectedProfileCell: ProfileCell? {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            return tableView.cellForRow(at: selectedIndexPath) as? ProfileCell
        }
        return nil
    }

    func profilePicturePositionInViewController() -> CGPoint? {
        if let cell = selectedProfileCell {
            let profilePicture = cell.profilePictureView!
            return cell.profileBoxView.convert(profilePicture.center, to: self.view)
        }

        return nil
    }

    
    // MARK: View Controller overrides
    
    override func viewDidLoad() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.view.backgroundColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false

        // table view
        tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 179
        tableView.separatorColor = UIColor.clear
        tableView.contentInset = UIEdgeInsetsMake(91, 0, 0, 0)
        self.tableView.setContentOffset(CGPoint(x:0, y:-91), animated: false)
        tableView.snapEdges(to: self.view)
        
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        addListeners()
        selectedProfileCell?.setSelected(false, animated: false)
        
        NotificationCenter.default.post(name: Event.menuShow, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeListeners()
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

    
    // MARK: Cell Related Animations, Positioning
    
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

    func hideCells() {
        if let cells = tableView.visibleCells as? [ProfileCell] {
            var selectedCellIndex: IndexPath!
            if let selectedProfileCell = selectedProfileCell {
                selectedCellIndex = tableView.indexPath(for: selectedProfileCell)
            } else {
                selectedCellIndex = IndexPath(row: -1, section: 0)
            }
            
            let totalRowCount = tableView.visibleCells.count

            cells.forEach({ (cell) in
                let cellIndex = self.tableView.indexPath(for: cell)!
                let rowDistance = abs(selectedCellIndex.row - cellIndex.row)
                if cellIndex.row > selectedCellIndex.row {
                    cell.animateVertical(direction: .down, rowDistance: rowDistance, totalRowCount: totalRowCount)
                } else if cellIndex.row < selectedCellIndex.row {
                    cell.animateVertical(direction: .up, rowDistance: rowDistance, totalRowCount: totalRowCount)
                }
            })

        }
    }

    func restoreCells() {
        if let cells = tableView.visibleCells as? [ProfileCell] {
            cells.forEach({ (cell) in
                cell.positionDefault()
            })
        }

        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: false)
        }

    }

    func positionProfilePictureIn(profileCell: ProfileCell) {
        profileCell.profilePictureView.positionIn(profileBox: profileCell.profileBoxView)
    }
    
    
    // MARK: Listeners / Handlers
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToMessagesHandler), name: Event.navigateToMessages, object: nil)
    }
    
    private func removeListeners() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    func navigateToMessagesHandler(notification: Notification) {
        self.navigationController?.pushViewController(MessageListViewController(), animated: true)
        self.navigationController?.viewControllers.remove(at: 0)
    }
}


// MARK: - View Controller Transition Animations

extension ProfileListViewController: AnimatedViewController {
    
    var estimatedInAnimationDuration: TimeInterval {
        return 1
    }
    
    var estimatedOutAnimationDuration: TimeInterval {
        return 1
    }
    
    func animateIn(_ completion: @escaping ()->Void) {
        anim { (settings) -> (animClosure) in
            settings.ease = .easeOutQuint
            settings.duration = 0.4
            return {
                NavigationBarController.shared.showProfile()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(600)) {
            completion()
        }
    }
    
    func animateOut(_ completion: @escaping ()->Void) {
        self.hideCells()
        
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInQuint
            settings.duration = 0.4
            return {
                NavigationBarController.shared.hide()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) {
            completion()
        }
    }
    
    func prepareForAnimateIn() {}
    
    func prepareForAnimateOut() {}
}


// MARK: - Cell

class ProfileCell: UITableViewCell {

    enum Direction {
        case up, down
    }

    var profileBoxView: UIView!
    var profilePictureView: ProfilePicture!
    private var inConstraint: NSLayoutConstraint!
    private var outConstraint: NSLayoutConstraint!
    private var topConstraint: NSLayoutConstraint!
    private var textContainerView: UIView!
    private var animations = [anim]()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = .none
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear

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

        UIView.alignMultiple(view: profileBoxView, to: containerView, attributes: [.width, .height])
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
        topConstraint = NSLayoutConstraint(item: profileBoxView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 0)
        containerView.addConstraint(topConstraint)

        // profile picture
        profilePictureView = ProfilePicture.create()
        profileBoxView.addSubview(profilePictureView)
        profilePictureView.positionIn(profileBox: profileBoxView)


        // text container
        textContainerView = UIView()
        textContainerView.translatesAutoresizingMaskIntoConstraints = false
        textContainerView.isUserInteractionEnabled = false
        profileBoxView.addSubview(textContainerView)

        profileBoxView.addConstraints([
            NSLayoutConstraint(item: textContainerView, attribute: .left, relatedBy: .equal, toItem: profileBoxView, attribute: .left, multiplier: 1, constant: 142),
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

    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            anim { (settings) -> (animClosure) in
                settings.duration = 0.1
                settings.ease = .easeInOutQuint
                return {
                    self.profileBoxView.backgroundColor = Color.midGray
                }
            }
            .then({ (settings) -> animClosure in
                settings.duration = 0.3
                settings.delay = 0.1
                settings.ease = .easeInQuad
                return {
                    self.alpha = 0
                    self.profileBoxView.backgroundColor = Color.lightGray
                    self.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
                }
            })
        } else {
            self.alpha = 1
            self.profileBoxView.backgroundColor = Color.lightGray
            self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
        }
    }

    
    // MARK: Position / Animate

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
        profilePictureView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
        a = anim { (settings) -> (animClosure) in
            settings.delay = 0.2
            settings.duration = 0.8
            settings.ease = .easeOutBack
            return {
                self.profilePictureView.adjustViewForProfileList()
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

    func animateVertical(direction: ProfileCell.Direction, rowDistance: Int, totalRowCount: Int) {
        let delay: TimeInterval = Double(totalRowCount - rowDistance - 1) * 0.09

        anim(constraintParent: contentView) { (settings) -> animClosure in
            settings.ease = .easeInSine
            settings.duration = 0.4
            settings.delay = delay
            return {
                switch direction {
                case .up:
                    self.topConstraint.constant = -600
                case .down:
                    self.topConstraint.constant = 600
                }
            }
        }

        self.profileBoxView.alpha = 1
        anim { (settings) -> (animClosure) in
            settings.ease = .easeInSine
            settings.duration = 0.4
            settings.delay = delay
            return {
                self.profileBoxView.alpha = 0
            }
        }
    }

    func positionDefault() {
        topConstraint.constant = 0
        profileBoxView.alpha = 1
        contentView.layoutIfNeeded()
    }
}


// MARK: - Profile Picture

extension ProfileCell {

    class ProfilePicture: UIView {

        var profilePictureForCell: UIImageView!
        var profilePictureForHeader: UIImageView!

        private var positionConstraints: [NSLayoutConstraint]?
        private var sizeConstaints: [NSLayoutConstraint]!

        class func create() -> ProfilePicture {
            let view = ProfilePicture()

            view.isUserInteractionEnabled = false
            view.sizeConstaints = view.size(width: 87, height: 87) //132

            view.profilePictureForCell = UIImageView(image: #imageLiteral(resourceName: "profile_picture_profile"))
            view.addSubview(view.profilePictureForCell)
            view.profilePictureForCell.snapEdges(to: view)
            view.profilePictureForHeader = UIImageView(image: #imageLiteral(resourceName: "profile_picture_header"))
            view.addSubview(view.profilePictureForHeader)
            view.profilePictureForHeader.snapEdges(to: view)

            view.adjustViewForProfileList()

            return view
        }
        
        // MARK: Position

        func positionIn(profileBox: UIView) {
            removePositionConstraints()

            profileBox.addSubview(self)
            positionConstraints = [
                UIView.align(view: self, to: profileBox, attribute: .left, constant: 28),
                UIView.align(view: self, to: profileBox, attribute: .centerY)
            ]
            self.layoutIfNeeded()
            
            sizeConstaints.forEach { (constraint) in
                constraint.constant = 87
            }
        }

        func positionIn(header: UIView) {
            removePositionConstraints()

            header.addSubview(self)
            positionConstraints = [
                NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: header, attribute: .centerX, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: header, attribute: .bottom, multiplier: 1, constant: -10)
            ]
            header.addConstraints(positionConstraints!)

            sizeConstaints.forEach { (constraint) in
                constraint.constant = 132
            }
        }

        func positionIn(view: UIView, position: CGPoint) {
            removePositionConstraints()

            view.addSubview(self)
            positionConstraints = [
                NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: position.x),
                NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: position.y)
            ]
            view.addConstraints(positionConstraints!)
        }

        func positionBackOnCellWhileOn(header: UIView, positionOnCell: CGPoint) {
            removePositionConstraints()

            header.addSubview(self)
            positionConstraints = [
                NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: header, attribute: .left, multiplier: 1, constant: positionOnCell.x),
                NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: header, attribute: .top, multiplier: 1, constant: positionOnCell.y)
            ]
            header.addConstraints(positionConstraints!)

            sizeConstaints.forEach { (constraint) in
                constraint.constant = 87
            }
        }

        func adjustViewForProfileList() {
            profilePictureForHeader.alpha = 0
        }

        func adjustViewForHeader() {
            profilePictureForHeader.alpha = 1
        }

        private func removePositionConstraints() {
            if let constraints = positionConstraints {
                self.superview?.removeConstraints(constraints)
            }
            positionConstraints?.removeAll()
        }

    }
}

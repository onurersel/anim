//
//  MessageDialogueViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-15.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit
import anim


// MARK: View Controller

class MessageDialogueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    fileprivate var messageTable: MessageTable!
    fileprivate var inputContainer: InputContainer!
    fileprivate var profilePicture: ProfilePicture!
    fileprivate var backBarButton: BackButton!
    private var conversation: Conversation!
    private(set) var userColor: UIColor!
    private var emitter: DialogueBubbleTableCell.Emitter!
    
    
    var lastRowIndexPath: IndexPath {
        return IndexPath(row: conversation.messages.count-1, section: 0)
    }
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor.white
        
        // color scheme
        userColor = Color.all.random
        
        // pre calculated conversation
        conversation = Conversation()
        conversation.createConversation(userColor: userColor)
        
        // input field
        inputContainer = InputContainer.create()
        inputContainer.position(on: self.view)
        
        // message table
        messageTable = MessageTable.create()
        self.view.insertSubview(messageTable, belowSubview: inputContainer)
        UIView.alignMultiple(view: messageTable, to: self.view, attributes: [.left, .top, .right])
        self.view.addConstraint(
            NSLayoutConstraint(item: messageTable, attribute: .bottom, relatedBy: .equal, toItem: inputContainer, attribute: .top, multiplier: 1, constant: 0)
        )
        
        messageTable.tableView.delegate = self
        messageTable.tableView.dataSource = self

        // back button
        backBarButton = BackButton.create()

        // profile picture
        profilePicture = ProfilePicture.create()

        // emitter
        emitter = DialogueBubbleTableCell.Emitter()
    }
    

    // MARK: View Controller Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NavigationBarController.shared.addItems(left: backBarButton, right: profilePicture)
        addListeners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeListeners()
        conversation.isClosed = true
        NavigationBarController.shared.addItems(left: nil, right: nil)
    }
    
    
    // MARK: Table View Delegates
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: DialogueBubbleTableCell.cellName) as? DialogueBubbleTableCell
                ??
            DialogueBubbleTableCell.create()
        
        showMessage(cell: cell, message: &conversation.messages[indexPath.row])
        
        return cell
    }

    private func showMessage(cell: DialogueBubbleTableCell, message: inout Message) {
        cell.prepareCell(message: message)
        
        if !message.didCreatedInitially && !message.didAppear {
            message.didAppear = true
            cell.animateIn(withEmitter: emitter)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    
    // MARK: Listeners / Actions
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowHandler), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideHandler), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addMessageHandler), name: Event.addMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateConversationTableHandler), name: Event.updateConversationTable, object: nil)
        
        backBarButton.addTarget(self, action: #selector(self.backAction), for: .touchUpInside)
    }
    
    private func removeListeners() {
        NotificationCenter.default.removeObserver(self)
        
        backBarButton.removeTarget(self, action: #selector(self.backAction), for: .touchUpInside)
    }
    
    @objc
    func keyboardWillShowHandler(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let finalFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt else {
                return
        }
        
        let distanceToBottom = finalFrame.size.height
        
        inputContainer.moveInputField(bottom: -distanceToBottom, duration: animationDuration, curve: animationCurve)
        scrollTableToLastCell()
    }
    
    @objc
    func keyboardWillHideHandler(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt else {
                return
        }
        inputContainer.moveInputField(bottom: 0, duration: animationDuration, curve: animationCurve)
    }
    
    @objc
    func addMessageHandler(notification: Notification) {
        guard let message = notification.userInfo?["message"] as? String else {
            return
        }
        
        conversation.addMessageFromUser(message)
        conversation.addMessageFromOtherAfterDelay()
    }
    
    @objc
    func updateConversationTableHandler(notification: Notification) {
        DispatchQueue.main.async {
            self.messageTable.tableView.reloadData()
            self.messageTable.tableView.layoutIfNeeded()
            self.scrollTableToLastCell()
        }
    }
    
    @objc
    func backAction() {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Scroll To Row
    
    fileprivate func scrollTableToLastCell(animated: Bool = true) {
        messageTable.tableView.setContentOffset(CGPoint(x: 0, y: messageTable.tableView.contentSize.height - messageTable.tableView.bounds.size.height + messageTable.tableView.contentInset.bottom), animated: animated)
    }
}


// MARK: - View Controller Transition Animations

extension MessageDialogueViewController: AnimatedViewController {
    var estimatedInAnimationDuration: TimeInterval {
        return 0.9
    }
    
    var estimatedOutAnimationDuration: TimeInterval {
        return 0.4
    }
    
    func animateIn(_ completion: @escaping ()->Void) {
        NotificationCenter.default.post(name: Event.menuHide, object: nil)
        NavigationBarController.shared.update(color: self.userColor)
        
        anim(constraintParent: messageTable) { (settings) -> animClosure in
            settings.duration = 0.8
            settings.ease = .easeOutQuint
            return {
                self.messageTable.positionForIn()
            }
        }
        
        
        
        anim { (settings) -> (animClosure) in
            settings.duration = 0.8
            settings.delay = 0.1
            settings.ease = .easeOutQuint
            return {
                NavigationBarController.shared.showMessage()
                self.profilePicture.alpha = 1
                self.backBarButton.alpha = 1
            }
        }
        .callback {
            completion()
        }
        
        scrollTableToLastCell(animated: true)
        inputContainer.positionForIn()
        inputContainer.showKeyboard()
    }
    
    func animateOut(_ completion: @escaping ()->Void) {
        inputContainer.positionForOut()
        inputContainer.hideKeyboard()

        anim { (settings) -> (animClosure) in
            settings.duration = 0.4
            settings.ease = .easeInQuint
            return {
                self.profilePicture.alpha = 0
                self.backBarButton.alpha = 0
            }
        }
        .callback {
            completion()
        }
        
        anim(constraintParent: messageTable) { (settings) -> animClosure in
            settings.duration = 0.46
            settings.ease = .easeInSine
            return {
                self.messageTable.positionForOut()
            }
        }
        .callback {
            NavigationBarController.shared.hide()
        }
    }
    
    func prepareForAnimateIn() {
        NavigationBarController.shared.hide()
        messageTable.positionForOut()
        inputContainer.positionForOut()
        profilePicture.alpha = 0
        backBarButton.alpha = 0
    }
    
    func prepareForAnimateOut() {
        NavigationBarController.shared.update(color: self.userColor)
        NavigationBarController.shared.showMessage()
        messageTable.positionForIn()
        inputContainer.positionForIn()
    }
}


// MARK: - Table View

extension MessageDialogueViewController {
    
    class MessageTable: UIView {
        
        private(set) var tableView: UITableView!
        
        private var topOutConstraint: NSLayoutConstraint!
        private var topInConstraint: NSLayoutConstraint!
        
        class func create() -> MessageTable {
            let view = MessageTable()
            
            
            // table view
            view.tableView = UITableView()
            view.addSubview(view.tableView)
            view.tableView.separatorStyle = .none
            view.tableView.allowsSelection = false
            view.tableView.rowHeight = UITableViewAutomaticDimension
            view.tableView.estimatedRowHeight = 56
            view.tableView.contentInset.top = 119
            view.tableView.contentInset.bottom = 30
            
            UIView.alignMultiple(view: view.tableView, to: view, attributes: [.width, .height])
            
            view.topOutConstraint = NSLayoutConstraint(item: view.tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
            view.topOutConstraint.priority = UILayoutPriority(rawValue: 999)
            view.topOutConstraint.isActive = false
            
            view.topInConstraint = NSLayoutConstraint(item: view.tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
            
            view.addConstraints([view.topOutConstraint, view.topInConstraint])
            
            return view
        }
        
        
        // MARK: Position
        
        func positionForOut() {
            tableView.clipsToBounds = false
            topOutConstraint.isActive = true
            topInConstraint.isActive = false
        }
        
        func positionForIn() {
            tableView.clipsToBounds = true
            topOutConstraint.isActive = false
            topInConstraint.isActive = true
        }
    }
    
}


// MARK: - Table View Cell

class DialogueBubbleTableCell: UITableViewCell {
    
    static let cellName = "dialogue_cell"
    
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var bubble: UIView!
    private var particleContainer: UIView!
    private var lines: UIImageView!
    private var label: UILabel!
    private var animation: anim?
    
    class func create() -> DialogueBubbleTableCell {
        let view = DialogueBubbleTableCell(style: .default, reuseIdentifier: DialogueBubbleTableCell.cellName)
        
        view.clipsToBounds = false
        view.backgroundColor = UIColor.clear
        view.contentView.clipsToBounds = false
        view.contentView.backgroundColor = UIColor.clear
        
        // particle container
        view.particleContainer = UIView()
        view.contentView.addSubview(view.particleContainer)
        view.particleContainer.translatesAutoresizingMaskIntoConstraints = false
        view.particleContainer.clipsToBounds = false
        view.particleContainer.isUserInteractionEnabled = false
        
        // bubble
        view.bubble = UIView()
        view.bubble.translatesAutoresizingMaskIntoConstraints = false
        view.contentView.addSubview(view.bubble)
        view.bubble.layer.cornerRadius = 20
        
        view.leftConstraint = NSLayoutConstraint(item: view.bubble, attribute: .left, relatedBy: .equal, toItem: view.contentView, attribute: .left, multiplier: 1, constant: 26)
        view.rightConstraint = NSLayoutConstraint(item: view.bubble, attribute: .right, relatedBy: .equal, toItem: view.contentView, attribute: .right, multiplier: 1, constant: -26)
        view.rightConstraint.priority = UILayoutPriority(rawValue: 999)
        
        view.contentView.addConstraints([
            NSLayoutConstraint(item: view.bubble, attribute: .width, relatedBy: .equal, toItem: view.contentView, attribute: .width, multiplier: 0.652, constant: 0),
            NSLayoutConstraint(item: view.bubble, attribute: .top, relatedBy: .equal, toItem: view.contentView, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: view.bubble, attribute: .bottom, relatedBy: .equal, toItem: view.contentView, attribute: .bottom, multiplier: 1, constant: -10)
            ])
        
        
        // label
        view.label = UILabel()
        view.bubble.addSubview(view.label)
        view.label.font = UIFont(name: Font.nameBlokk, size: 19)
        view.label.textColor = UIColor.white
        view.label.numberOfLines = 100
        view.label.translatesAutoresizingMaskIntoConstraints = false
        
        view.bubble.addConstraints([
            NSLayoutConstraint(item: view.label, attribute: .left, relatedBy: .equal, toItem: view.bubble, attribute: .left, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: view.label, attribute: .right, relatedBy: .equal, toItem: view.bubble, attribute: .right, multiplier: 1, constant: -20),
            NSLayoutConstraint(item: view.label, attribute: .top, relatedBy: .equal, toItem: view.bubble, attribute: .top, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: view.label, attribute: .bottom, relatedBy: .equal, toItem: view.bubble, attribute: .bottom, multiplier: 1, constant: -20),
            ])
        
        // particle container aligning
        view.contentView.addConstraints([
            NSLayoutConstraint(item: view.particleContainer, attribute: .centerX, relatedBy: .equal, toItem: view.bubble, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: view.particleContainer, attribute: .centerY, relatedBy: .equal, toItem: view.bubble, attribute: .centerY, multiplier: 1, constant: 0),
            ])
        
        return view
    }
    
    
    // MARK: Prepare Cell
    
    func prepareCell(message: MessageDialogueViewController.Message) {
        label.attributedText = message.body.attributedBlock
        switch message.side {
        case .left:
            alignLeft()
        case .right:
            alignRight()
        }
        bubble.backgroundColor = message.color
    }
    
    private func alignLeft() {
        contentView.removeConstraint(rightConstraint)
        contentView.addConstraint(leftConstraint)
    }
    
    private func alignRight() {
        contentView.addConstraint(rightConstraint)
        contentView.removeConstraint(leftConstraint)
    }
    
    
    // MARK: Animate
    
    func animateIn(withEmitter emitter: Emitter) {
        
        bubble.alpha = 0
        bubble.transform = CGAffineTransform.identity.scaledBy(x: 0.4, y: 0.4)
        
        animation?.stop()
        
        animation = anim { (settings) -> (animClosure) in
            settings.delay = 0.1
            settings.duration = 0
            return {}
            }
            .callback {
                emitter.fire(view: self.particleContainer, position:CGPoint(x:0, y:0), bubbleSize: self.bubble.bounds.size, color: self.bubble.backgroundColor!)
            }
            .then { (settings) -> (animClosure) in
                settings.duration = 0.35
                settings.ease = .easeOutQuint
                return {
                    self.bubble.alpha = 1
                    self.bubble.transform = CGAffineTransform.identity.scaledBy(x: 1.04, y: 1.04)
                }
            }
            .then { (settings) -> animClosure in
                settings.duration = 0.2
                settings.ease = .easeInOutQuad
                return {
                    self.bubble.transform = CGAffineTransform.identity.scaledBy(x: 0.99, y: 0.99)
                }
            }
            .then { (settings) -> animClosure in
                settings.duration = 0.1
                settings.ease = .easeInOutSine
                settings.delay = 0.1
                return {
                    self.bubble.transform = CGAffineTransform.identity
                }
        }
    }
    
}


// MARK: - Message

extension MessageDialogueViewController {
    
    struct Message {
        
        enum Side {
            case left, right
            
            static var random: Side {
                return (DoubleRange.random01 < 0.5) ? .left : .right
            }
            
            var opposite: Side {
                return (self == .left) ? .right : .left
            }
        }
        
        init(side: Side, color: UIColor, body: String) {
            self.side = side
            self.color = color
            self.body = body
        }
        
        var side: Side
        var color: UIColor
        var body: String
        var didAppear: Bool = false
        var didCreatedInitially: Bool = false
    }
    
}


// MARK: - Conversation

extension MessageDialogueViewController {
    
    class Conversation {
        
        var messages = [Message]()
        var isClosed: Bool = false
        private var userColor: UIColor!
        
        
        // MARK: Create Initial Conversation
        
        func createConversation(userColor: UIColor) {
            self.userColor = userColor
            
            let messageCount = Int(DoubleRange(min: 1, max: 8).random)
            messages.removeAll()
            
            var side: Message.Side?
            var oppositeSideChance: Double = 0
            
            for _ in 0...messageCount {
                
                var body: String!
                var color: UIColor!
                
                // side
                if side == nil {
                    side = Message.Side.random
                    oppositeSideChance = 0.5
                } else {
                    if DoubleRange.random01 < oppositeSideChance {
                        side = side!.opposite
                        oppositeSideChance = 0.5
                    } else {
                        oppositeSideChance += 0.2
                    }
                }
                
                // body
                body = Dummy.message
                
                // color
                switch side! {
                case .left:
                    color = Color.lightGray
                case .right:
                    color = userColor
                }
                
                var message = Message(side: side!, color: color, body: body)
                message.didCreatedInitially = true
                messages.append(message)
            }
        }
        
        
        // MARK: Add Message
        
        func addMessageFromUser(_ message: String) {
            messages.append( Message(side: .right, color: userColor, body: message) )
            NotificationCenter.default.post(name: Event.updateConversationTable, object: nil)
        }
        
        func addMessageFromOther() {
            messages.append( Message(side: .left, color: Color.lightGray, body: Dummy.message) )
            NotificationCenter.default.post(name: Event.updateConversationTable, object: nil)
        }
        
        func addMessageFromOtherAfterDelay() {
            var delay = Int(DoubleRange(min: 1.7, max: 8).random * 1000)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
                if !self.isClosed {
                    self.addMessageFromOther()
                }
            }
            
            if DoubleRange.random01 < 0.2 {
                delay += Int(DoubleRange(min: 2, max: 6).random * 1000)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delay)) {
                    if !self.isClosed {
                        self.addMessageFromOther()
                    }
                }
            }
        }
    }
    
}


// MARK: - Profile Picture

extension MessageDialogueViewController {
    
    class ProfilePictureBarButtonItem: UIBarButtonItem {
        
        var pictureView: ProfilePicture!
        
        class func create() -> ProfilePictureBarButtonItem {
            let view = ProfilePicture.create()
            let barItem = ProfilePictureBarButtonItem(customView: view)
            barItem.pictureView = view
            return barItem
        }
        
    }
    
}

extension MessageDialogueViewController {

    class ProfilePicture: UIView {
        
        class func create() -> ProfilePicture {
            let view = ProfilePicture()
            view.size(width: 52, height: 52)
            view.backgroundColor = Color.darkGray
            view.layer.cornerRadius = 26
            
            return view
        }
        
    }
    
}


// MARK: - Input Container

extension MessageDialogueViewController {
    
    class InputContainer: UIView, UITextFieldDelegate {
        
        private var bottomOutConstraint: NSLayoutConstraint!
        private var bottomInConstraint: NSLayoutConstraint!
        private var parent: UIView!
        private var textField: InputField!
        
        class func create() -> InputContainer {
            let view = InputContainer()
            view.backgroundColor = Color.midGray
            
            view.textField = InputField.create()
            view.textField.delegate = view
            view.addSubview(view.textField)
            
            
            view.addConstraints([
                NSLayoutConstraint(item: view.textField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: view.textField, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 16),
                NSLayoutConstraint(item: view.textField, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10),
                NSLayoutConstraint(item: view.textField, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -16)
                ])
            
            return view
        }
        
        
        // MARK: Position
        
        func position(on parent: UIView) {
            self.parent = parent
            parent.addSubview(self)
            
            parent.addSubview(self)
            self.translatesAutoresizingMaskIntoConstraints = false
            
            bottomInConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: parent, attribute: .bottom, multiplier: 1, constant: 0)
            bottomOutConstraint = NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: parent, attribute: .bottom, multiplier: 1, constant: 0)
            bottomOutConstraint.priority = UILayoutPriority(rawValue: 999)
            bottomOutConstraint.isActive = false
            parent.addConstraints([
                NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: parent, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: parent, attribute: .right, multiplier: 1, constant: 0),
                bottomInConstraint,
                bottomOutConstraint
                ])
            
            self.addConstraint(
                NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 56)
            )
        }
        
        
        func moveInputField(bottom: CGFloat, duration: TimeInterval, curve: UInt) {
            parent.layoutIfNeeded()
            
            // don't support raw curves yet 😔
            UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions(rawValue: curve), animations: {
                self.bottomInConstraint.constant = bottom
                self.bottomOutConstraint.constant = bottom
                self.parent.layoutIfNeeded()
            }, completion: nil)
        }
        
        func positionForOut() {
            bottomOutConstraint.isActive = true
            bottomInConstraint.isActive = false
        }
        
        func positionForIn() {
            bottomOutConstraint.isActive = false
            bottomInConstraint.isActive = true
        }
        
        
        // MARK: Text Field Delegate
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let textEntered = textField.text, !textEntered.isEmpty else {
                return false
            }
            
            textField.text = ""
            NotificationCenter.default.post(name: Event.addMessage, object: nil, userInfo: ["message": textEntered])
            
            return true
        }
        
        
        // MARK: Show / Hide Keyboard
        
        func showKeyboard() {
            textField.becomeFirstResponder()
        }
        
        func hideKeyboard() {
            textField.resignFirstResponder()
        }
        
    }
}


// MARK: Input Field

extension MessageDialogueViewController {
    
    class InputField: UITextField {
        
        class func create() -> InputField {
            let view = InputField()
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = UIColor.white
            view.autocorrectionType = .no
            view.spellCheckingType = .no
            view.layer.cornerRadius = 14
            
            view.textColor = UIColor.lightGray
            view.font = UIFont(name: Font.nameBlokk, size: 19)
            
            return view
        }
        
        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return self.bounds.insetBy(dx: 20, dy: 0)
        }
        
    }
    
}

//
//  MessageDialogueViewController.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-15.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit

class MessageDialogueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    private var tableView: UITableView!
    private var conversation: Conversation!
    private var userColor: UIColor!
    private var inputContainer: InputContainer!
    
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
        
        // table view
        tableView = UITableView()
        self.view.addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56
        tableView.contentInset.bottom = 30
        UIView.alignMultiple(view: tableView, to: self.view, attributes: [.left, .top, .right])
        self.view.addConstraint(
            NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: inputContainer, attribute: .top, multiplier: 1, constant: 0)
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // back button
        let backButton = BackBarButtonItem.create()
        self.navigationItem.leftBarButtonItem = backButton
        
        // profile picture
        let profilePicture = ProfilePicture.createBarItem()
        self.navigationItem.rightBarButtonItem = profilePicture
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NavigationBarController.shared.showMessage(color: userColor)
        
        NotificationCenter.default.post(name: Event.MenuHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addListeners()
        inputContainer.showKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeListeners()
        conversation.isClosed = true
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: DialogueBubbleTableCell.cellName) as? DialogueBubbleTableCell
                ??
            DialogueBubbleTableCell.create()
        
        cell.prepareCell(message: conversation.messages[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    private func addListeners() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowHandler), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideHandler), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.addMessageHandler), name: Event.AddMessage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateConversationTableHandler), name: Event.UpdateConversationTable, object: nil)
    }
    
    private func removeListeners() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func scrollTableToLastCell() {
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.bounds.size.height + self.tableView.contentInset.bottom), animated: true)
    }
    
    @objc
    func keyboardWillShowHandler(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let finalFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        let distanceToBottom = finalFrame.size.height
        
        inputContainer.moveInputField(bottom: -distanceToBottom)
        scrollTableToLastCell()
    }
    
    @objc
    func keyboardWillHideHandler(notification: Notification) {
        inputContainer.moveInputField(bottom: 0)
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
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.scrollTableToLastCell()
        }
    }
}

class DialogueBubbleTableCell: UITableViewCell {
    
    static let cellName = "dialogue_cell"
    
    private var leftConstraint: NSLayoutConstraint!
    private var rightConstraint: NSLayoutConstraint!
    private var bubble: UIView!
    private var label: UILabel!
    
    class func create() -> DialogueBubbleTableCell {
        let view = DialogueBubbleTableCell(style: .default, reuseIdentifier: DialogueBubbleTableCell.cellName)
        
        view.bubble = UIView()
        view.bubble.translatesAutoresizingMaskIntoConstraints = false
        view.contentView.addSubview(view.bubble)
        view.bubble.layer.cornerRadius = 20
        
        view.leftConstraint = NSLayoutConstraint(item: view.bubble, attribute: .left, relatedBy: .equal, toItem: view.contentView, attribute: .left, multiplier: 1, constant: 26)
        view.rightConstraint = NSLayoutConstraint(item: view.bubble, attribute: .right, relatedBy: .equal, toItem: view.contentView, attribute: .right, multiplier: 1, constant: -26)
        view.rightConstraint.priority = 999
        
        view.contentView.addConstraints([
            NSLayoutConstraint(item: view.bubble, attribute: .width, relatedBy: .equal, toItem: view.contentView, attribute: .width, multiplier: 0.652, constant: 0),
            NSLayoutConstraint(item: view.bubble, attribute: .top, relatedBy: .equal, toItem: view.contentView, attribute: .top, multiplier: 1, constant: 10),
            NSLayoutConstraint(item: view.bubble, attribute: .bottom, relatedBy: .equal, toItem: view.contentView, attribute: .bottom, multiplier: 1, constant: -10)
            ])
        
        
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
        
        return view
    }
    
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
    
}


// MARK: - Conversation

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
        
        var side: Side
        var color: UIColor
        var body: String
    }
    
    class Conversation {
        
        var messages = [Message]()
        var isClosed: Bool = false
        private var userColor: UIColor!
        
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
                
                messages.append(Message(side: side!, color: color, body: body))
            }
        }
        
        func addMessageFromUser(_ message: String) {
            messages.append( Message(side: .right, color: userColor, body: message) )
            NotificationCenter.default.post(name: Event.UpdateConversationTable, object: nil)
        }
        
        func addMessageFromOther() {
            messages.append( Message(side: .left, color: Color.lightGray, body: Dummy.message) )
            NotificationCenter.default.post(name: Event.UpdateConversationTable, object: nil)
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

    class ProfilePicture: UIView, RightNavigationBarButton {
        
        class func create() -> ProfilePicture {
            let view = ProfilePicture()
            view.size(width: 52, height: 52)
            view.backgroundColor = Color.darkGray
            view.layer.cornerRadius = 26
            
            return view
        }
        
        class func createBarItem() -> UIBarButtonItem {
            let view = ProfilePicture.create()
            let barItem = UIBarButtonItem(customView: view)
            return barItem
        }
    }
    
}

extension MessageDialogueViewController {
    
    class InputContainer: UIView, UITextFieldDelegate {
        
        private var bottomConstraint: NSLayoutConstraint!
        private var parent: UIView!
        private var textField: UITextField!
        
        class func create() -> InputContainer {
            let view = InputContainer()
            view.backgroundColor = Color.midGray
            
            view.textField = UITextField()
            view.addSubview(view.textField)
            view.textField.translatesAutoresizingMaskIntoConstraints = false
            view.textField.backgroundColor = UIColor.green
            view.textField.delegate = view
            view.textField.autocorrectionType = .no
            view.textField.spellCheckingType = .no
            
            view.addConstraints([
                NSLayoutConstraint(item: view.textField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: view.textField, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: view.textField, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10),
                NSLayoutConstraint(item: view.textField, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -10)
                ])
            
            return view
        }
        
        func position(on parent: UIView) {
            self.parent = parent
            parent.addSubview(self)
            
            parent.addSubview(self)
            self.translatesAutoresizingMaskIntoConstraints = false
            
            bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: parent, attribute: .bottom, multiplier: 1, constant: 0)
            parent.addConstraints([
                NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: parent, attribute: .left, multiplier: 1, constant: 0),
                NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: parent, attribute: .right, multiplier: 1, constant: 0),
                bottomConstraint
                ])
            self.addConstraint(
                NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 100)
            )
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard let textEntered = textField.text else {
                return false
            }
            
            textField.text = ""
            NotificationCenter.default.post(name: Event.AddMessage, object: nil, userInfo: ["message": textEntered])
            
            return true
        }
        
        func showKeyboard() {
            textField.becomeFirstResponder()
        }
        
        func hideKeyboard() {
            textField.resignFirstResponder()
        }
        
        func moveInputField(bottom: CGFloat) {
            bottomConstraint.constant = bottom
            parent.layoutIfNeeded()
        }
    }
    
}

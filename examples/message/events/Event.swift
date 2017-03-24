//
//  Event.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-28.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

struct Event {
    static let menuToggle = NSNotification.Name(rawValue: "menu_toggle")
    static let menuStateChange = NSNotification.Name(rawValue: "menu_state_change")
    static let menuHide = NSNotification.Name(rawValue: "menu_hide")
    static let menuShow = NSNotification.Name(rawValue: "menu_show")
    static let conversationScroll = NSNotification.Name(rawValue: "conversation_scroll")
    static let addMessage = NSNotification.Name(rawValue: "add_message")
    static let updateConversationTable = NSNotification.Name(rawValue: "update_conversation_table")
    static let navigateToConversation = NSNotification.Name(rawValue: "navigate_to_conversation")
    static let navigateToProfile = NSNotification.Name(rawValue: "navigate_to_profile")
    static let navigateToMessages = NSNotification.Name(rawValue: "navigate_to_messages")
}

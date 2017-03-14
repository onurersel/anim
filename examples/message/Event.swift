//
//  Event.swift
//  anim
//
//  Created by Onur Ersel on 2017-02-28.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

struct Event {
    static let MenuToggle = NSNotification.Name(rawValue: "menu_toggle")
    static let MenuStateChange = NSNotification.Name(rawValue: "menu_state_change")
    static let MenuHide = NSNotification.Name(rawValue: "menu_hide")
    static let MenuShow = NSNotification.Name(rawValue: "menu_show")
    static let ConversationScroll = NSNotification.Name(rawValue: "conversation_scroll")
}

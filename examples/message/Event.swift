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
    static let ShowProfileDetail = NSNotification.Name(rawValue: "show_profile_detail")
}

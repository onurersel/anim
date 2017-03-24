//
//  Foundation.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-14.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation

extension Array where Element: Any {
    var random: Element {
        return self[self.count.randomTill]
    }
}

//
//  Style.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-01.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit


struct Color {
    
    static let lightGray    = UIColor(red: 219/255.0, green: 228/255.0, blue: 228/255.0, alpha: 1)
    static let midGray      = UIColor(red: 187/255.0, green: 193/255.0, blue: 195/255.0, alpha: 1)
    static let darkGray     = UIColor(red: 40/255.0, green: 45/255.0, blue: 47/255.0, alpha: 1)
    static let red          = UIColor(red: 255/255.0, green: 66/255.0, blue: 85/255.0, alpha: 1)
    static let orange       = UIColor(red: 232/255.0, green: 165/255.0, blue: 48/255.0, alpha: 1)
    
}

struct Font {
    static let nameBlokk    = "BLOKKNeue-Regular"
}

extension String {
    var attributedBlock: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        attributedString.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSRange(location: 0, length: self.characters.count))
        
        return attributedString
    }
}

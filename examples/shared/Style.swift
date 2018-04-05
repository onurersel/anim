//
//  Style.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-01.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import UIKit


struct Color {
    
    static let lightGray    = UIColor(red: 219.0/255.0, green: 228.0/255.0, blue: 228.0/255.0, alpha: 1)
    static let midGray      = UIColor(red: 187.0/255.0, green: 193.0/255.0, blue: 195.0/255.0, alpha: 1)
    static let darkGray     = UIColor(red: 40.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 1)
    static let red          = UIColor(red: 255.0/255.0, green: 66.0/255.0, blue: 85.0/255.0, alpha: 1)
    static let orange       = UIColor(red: 232.0/255.0, green: 165.0/255.0, blue: 48.0/255.0, alpha: 1)
    static let yellow       = UIColor(red: 240.0/255.0, green: 243.0/255.0, blue: 8.0/255.0, alpha: 1)
    static let lightGreen   = UIColor(red: 207.0/255.0, green: 255.0/255.0, blue: 136.0/255.0, alpha: 1)
    static let blue         = UIColor(red: 85.0/255.0, green: 48.0/255.0, blue: 232.0/255.0, alpha: 1)
    static let green        = UIColor(red: 79.0/255.0, green: 173.0/255.0, blue: 167.0/255.0, alpha: 1)
    
    static let all          = [red, orange, yellow, lightGreen, blue, green]
}

struct Font {
    static let nameBlokk    = "BLOKKNeue-Regular"
}

extension String {
    var attributedBlock: NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 12
        attributedString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: NSRange(location: 0, length: self.count))
        
        return attributedString
    }
}

//
//  Dummy.swift
//  anim
//
//  Created by Onur Ersel on 2017-03-02.
//  Copyright (c) 2017 Onur Ersel. All rights reserved.

import Foundation


struct Dummy {

    static let words = ["aa", "aaa", "aaaa", "aaaaa", "aaaaaa", "aaaaaaa"]

    static var randomWord: String {
        let randomIndex = Int(floor((Double(words.count)-0.00001) * DoubleRange.random01))
        return words[randomIndex]
    }

    static var text: String {
        return text(10)
    }

    static var message: String {
        return text(DoubleRange(min: 1, max: 8).random.int)
    }
    
    static func text(_ length: Int) -> String {
        var str = ""
        for _ in 0..<length {
            str += "\(randomWord) "
        }

        return str
    }

}

//
//  String.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

extension String {
    func length() -> Int {
        return self.characters.count
    }
    
    func substring(start: Int, length: Int) -> String {
        return (self as NSString).substringWithRange(NSRange(location: start, length: length))
    }
    
    func substring(range: NSRange) -> String {
        let fromUTF16 = self.utf16.startIndex.advancedBy(range.location, limit: self.utf16.endIndex)
        let toUTF16 = fromUTF16.advancedBy(range.length, limit: self.utf16.endIndex)
        if let from = String.Index(fromUTF16, within: self),
            let to = String.Index(toUTF16, within: self) {
                return self[from ..< to]
        } else {
            // TODO: return exception
            return ""
        }
    }
}
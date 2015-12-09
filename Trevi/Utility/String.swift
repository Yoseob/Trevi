//
//  String.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum StringError : ErrorType {
    case UnsupportedEncodingError
}

extension String {
    func length() -> Int {
        return self.characters.count
    }
    
    func substring(start: Int, length: Int) -> String {
        return self[self.startIndex.advancedBy(start) ..< self.startIndex.advancedBy(start + length)]
    }
    
    func getIndex(location: Int, encoding: UInt = NSUnicodeStringEncoding) throws -> String.Index {
        switch(encoding) {
        case NSUTF8StringEncoding:
            return String.Index(utf8.startIndex.advancedBy(location, limit: utf8.endIndex), within: self)!
        case NSUTF16StringEncoding:
            return String.Index(utf16.startIndex.advancedBy(location, limit: utf16.endIndex), within: self)!
        case NSUnicodeStringEncoding:
            return startIndex.advancedBy(location)
        default:
            throw StringError.UnsupportedEncodingError
        }
    }
}
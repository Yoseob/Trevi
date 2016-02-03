//
//  String.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public let CRLF = "\r\n"
public let SP = " "
public let HT = "\t"

//public enum UrlRegex: String {
//    case unreserved = "\\w\\-\\.\\_\\~"
//    case gen_delims = "\\:\\/\\?\\#\\[\\]\\@"
//    case sub_delims = "\\!\\$\\&\\'\\(\\)\\*\\+\\,\\;\\="
//}
public let unreserved = "\\w\\-\\.\\_\\~"
public let gen_delims = "\\:\\/\\?\\#\\[\\]\\@"
public let sub_delims = "\\!\\$\\&\\'\\(\\)\\*\\+\\,\\;\\="

public enum StringError: ErrorType {
    case UnsupportedEncodingError
}

public extension String {
    
    func length () -> Int {
        return self.characters.count
    }
    
    func trim () -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

    func substring ( start: Int, length: Int ) -> String {
        return self[self.startIndex.advancedBy ( start ) ..< self.startIndex.advancedBy ( start + length )]
    }

    func getIndex ( location: Int, encoding: UInt = NSUnicodeStringEncoding ) throws -> String.Index {
        switch (encoding) {
        case NSUTF8StringEncoding:
            return String.Index ( utf8.startIndex.advancedBy ( location, limit: utf8.endIndex ), within: self )!
        case NSUTF16StringEncoding:
            return String.Index ( utf16.startIndex.advancedBy ( location, limit: utf16.endIndex ), within: self )!
        case NSUnicodeStringEncoding:
            return startIndex.advancedBy ( location )
        default:
            throw StringError.UnsupportedEncodingError
        }
    }
    
    // TODO : Which one better? it needs testing..
    func isMatch( regex: String ) -> Bool {
        if let _ = self.rangeOfString( regex, options: .RegularExpressionSearch) {
            return true
        } else {
            return false
        }
//        if let exp = try? NSRegularExpression( pattern: regex, options: [] ) {
//            return exp.numberOfMatchesInString( self, options: [], range: NSMakeRange(0, self.characters.count) ) > 0
//        } else {
//            return false
//        }
    }
}
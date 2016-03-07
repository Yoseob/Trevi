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
public let unreserved = "\\w\\-\\.\\_\\~"
public let gen_delims = "\\:\\/\\?\\#\\[\\]\\@"
public let sub_delims = "\\!\\$\\&\\'\\(\\)\\*\\+\\,\\;\\="
public let __dirname = NSFileManager.defaultManager().currentDirectoryPath

public enum StringError: ErrorType {
    case UnsupportedEncodingError
}

#if os(Linux)
// Wrapper for casting between AnyObject and String
public class StringWrapper {
    public var string: String

    public init(string: String) {
        self.string = string
    }
}
#endif

extension String {
    public func length() -> Int {
        return self.characters.count
    }
    
    public func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }

    public func substring(start: Int, length: Int) -> String {
        return self[self.startIndex.advancedBy(start) ..< self.startIndex.advancedBy(start + length)]
    }

    public func getIndex(location: Int, encoding: UInt = NSUnicodeStringEncoding) throws -> String.Index {
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
    public func isMatch(regex: String) -> Bool {
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

/**
 - Parameter string: The string to search.
 - Parameter pattern: The regular expression pattern to compile.
 - Parameter options: The regular expression options that are applied to the expression during matching. See NSRegularExpressionOptions for possible values.
 
 - Returns: An array of tuples that include NSRange and String which are searched with regular expression.
 */
public func searchWithRegularExpression ( string: String, pattern: String, options: NSRegularExpressionOptions = [] ) -> [[String : (range: NSRange, text: String)]] {
    var searched = [[String : (range: NSRange, text: String)]]()
    
    if let regex: NSRegularExpression = try? NSRegularExpression ( pattern: pattern, options: options ) {
        for matches in regex.matchesInString ( string, options: [], range: NSMakeRange( 0, string.characters.count ) ) {
            var group = [String : (range: NSRange, text: String)]()
            for idx in 0 ..< matches.numberOfRanges {
                let range = matches.rangeAtIndex( idx )
                group.updateValue((matches.rangeAtIndex(idx), string[string.startIndex.advancedBy(range.location) ..< string.startIndex.advancedBy(range.location + range.length)]), forKey: "$\(idx)")
            }
            searched.append(group)
        }
    }
    
    return searched
}


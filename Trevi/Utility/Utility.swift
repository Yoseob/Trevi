//
//  Utility.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public let __dirname = NSFileManager.defaultManager().currentDirectoryPath

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
    
    public func getIndex(location: Int, encoding: UInt = NSUnicodeStringEncoding) -> String.Index? {
        switch (encoding) {
        case NSUTF8StringEncoding:
            return String.Index ( utf8.startIndex.advancedBy ( location, limit: utf8.endIndex ), within: self )!
        case NSUTF16StringEncoding:
            return String.Index ( utf16.startIndex.advancedBy ( location, limit: utf16.endIndex ), within: self )!
        case NSUnicodeStringEncoding:
            return startIndex.advancedBy ( location )
        default:
            return nil
        }
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

public func getCurrentDatetime(format: String = "yyyy/MM/dd hh:mm:ss a z") -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = format
    return formatter.stringFromDate(NSDate())
}

public func bridge<T : AnyObject>(obj : T) -> UnsafePointer<Void> {
    return UnsafePointer(Unmanaged.passUnretained(obj).toOpaque())
}

public func bridge<T : AnyObject>(ptr : UnsafePointer<Void>) -> T {
    return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
}
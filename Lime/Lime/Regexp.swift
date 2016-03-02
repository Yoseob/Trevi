//
//  Regexp.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class RegExp {
    public var fastSlash: Bool!     // middleware only true
    public var source: String!      // Regular expression for path
    public var originPath: String!
    
    public init() {
        self.fastSlash = false
        self.source = ""
    }
    
    public init(path: String) {
        fastSlash = false
        originPath = path
        
        if path.length() > 1 {
            // remove if the first of url is slash
            if path.characters.first == "/" {
                source = "^\\/*\(path[path.startIndex.successor() ..< path.endIndex])/?.*"
            } else {
                source = "^\\/*\(path)/?.*"
            }
            
            for param in searchWithRegularExpression(source, pattern: "(:[^\\/]+)") {
                source = source.stringByReplacingOccurrencesOfString(param["$1"]!.text, withString: "([^\\/]+)")
            }
            
            for param in searchWithRegularExpression(originPath, pattern: "(:[^\\/]+)") {
                originPath = originPath.stringByReplacingOccurrencesOfString(param["$1"]!.text, withString: ".*")
            }
        }
    }
    
    public func exec(path: String) -> [String]? {
        var result: [String]? = nil
        
        if (path == originPath) && path == "/" && source == nil {
            result = [path]
            return result
        }
        if source == nil {
            return result
        }
        
        for param in searchWithRegularExpression(path, pattern: "(\(originPath))(?:.*)") {
            if result == nil {
                result = [String]()
                result!.append(param["$1"]!.text)
            }
            
            for params in searchWithRegularExpression(path, pattern: source) {
                for idx in 1 ..< params.count {
                    result!.append(params["$\(idx)"]!.text)
                }
            }
        }
        
        return result
    }
}

public struct Option{
    public var end: Bool = false
    public init(end: Bool){
        self.end = end
    }
}



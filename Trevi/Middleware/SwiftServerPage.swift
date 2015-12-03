//
//  SwiftServerPage.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class SwiftServerPage : Middleware {
    
    // TODO: move to abstract class...
    public private(set) var name: MiddlewareName! {
        get { return self.name }
        set (name) { self.name = name }
    }

    public init(){
        name = .SwiftServerPage
    }

    public func operateCommand(obj: AnyObject...) {
        var req : Request = obj[0] as! Request;
        let r : Route = obj[1] as! Route

    }
    
    public func compilePage(filepath: String) {

        let data: String = FileIO.read(filepath)

        if let regex: NSRegularExpression = try NSRegularExpression(pattern: "<% *(.+?) *%>", options: [.CaseInsensitive]) {
            var swiftCode: String = ""
            let matches = regex.matchesInString(data, options: [], range: NSMakeRange(0, data.characters.count))
            for match in matches {
                let range = match.rangeAtIndex(1)
                let substring: String = data.substring(range.location, length: range.length)
                swiftCode += substring + "\n"
            }

            if swiftCode != "" {
                FileIO.write("\(filepath).swift", data: swiftCode);

                let complied = System.executeCmd("/usr/bin/swift", args: ["\(filepath).swift"])
                print("[output]\n\(complied)")
            }
        }
    }

}
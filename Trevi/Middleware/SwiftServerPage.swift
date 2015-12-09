//
//  SwiftServerPage.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class SwiftServerPage : Middleware {
    
    public var name : MiddlewareName;
    private var filepath: String = ""
    
    public init(){
        name = .SwiftServerPage
    }
    
    public func operateCommand(params : MiddlewareParams) -> Bool {
        let req : Request = params.req
        let res : Response = params.res
        let route : Route = params.route
        
        filepath = "/Users/dragonznet/Documents/index.ssp"
        let compiled = compileConvertedSwift(convertSSPtoSwift(loadFile(filepath)))
        res.bodyString = compiled;
        return true
    }
    
    func loadFile(filepath: String) -> String {
        return FileIO.read(filepath, encoding: NSUTF8StringEncoding)
    }
    
    func convertSSPtoSwift(data: String) -> String {
        var swiftCode: String = ""
        
        if let regex: NSRegularExpression = try? NSRegularExpression(pattern: "(<%=?)[ \\t\\n]*([\\w\\W]+?)[ \\t\\n]*%>", options: [.CaseInsensitive]) {
            var startIdx = data.startIndex
            
            for match in regex.matchesInString(data, options: [], range: NSMakeRange(0, data.length())) {
                let tagRange = match.rangeAtIndex(0)
                let contentsRange = match.rangeAtIndex(2)
                let swiftTag, htmlTag: String
                
                if data.substring(match.rangeAtIndex(1).location, length: match.rangeAtIndex(1).length) == "<%=" {
                    swiftTag = "print(\(data.substring(contentsRange.location, length: contentsRange.length)), terminator:\"\")"
                } else {
                    swiftTag = data.substring(contentsRange.location, length: contentsRange.length)
                }
                htmlTag = data[startIdx ..< data.startIndex.advancedBy(tagRange.location)]
                    .stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
                    .stringByReplacingOccurrencesOfString("\t", withString: "{@t}")
                    .stringByReplacingOccurrencesOfString("\n", withString: "{@n}")
                
                swiftCode += "print(\"\(htmlTag)\", terminator:\"\")\n\(swiftTag)\n"
                
                startIdx = data.startIndex.advancedBy(tagRange.location + tagRange.length)
            }
            let htmlTag = data[startIdx ..< data.endIndex]
                .stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
                .stringByReplacingOccurrencesOfString("\t", withString: "{@t}")
                .stringByReplacingOccurrencesOfString("\n", withString: "{@n}")
            swiftCode += "print(\"\(htmlTag)\")\n"
        } else {
            print("Error parsing data.")
        }
        
        return swiftCode
    }
    
    func compileConvertedSwift(swiftCode: String) -> String {
        FileIO.write("\(filepath).swift", data: swiftCode, encoding: NSUTF8StringEncoding)
        let complied = System.executeCmd("/usr/bin/swift", args: ["\(filepath).swift"])
            .stringByReplacingOccurrencesOfString("{@t}", withString: "\t")
            .stringByReplacingOccurrencesOfString("{@n}", withString: "\n")
        return complied
    }
}
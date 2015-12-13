//
//  SwiftServerPage.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public protocol Renderer {
    func render ( filename: String ) -> String
    func render ( filename: String, args: [String:String] ) -> String
}

public class SwiftServerPage: Middleware, Renderer {

    public var name: MiddlewareName;

    public init () {
        name = .SwiftServerPage
    }

    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        let res: Response = params.res
        res.renderer = self
        return false
    }

    public func render ( filename: String ) -> String {
        return compileConvertedSwift ( filename, swiftCode: convertSSPtoSwift ( loadFile ( filename ), args: [:] ) )!
    }

    public func render ( filename: String, args: [String:String] ) -> String {
        return compileConvertedSwift ( filename, swiftCode: convertSSPtoSwift ( loadFile ( filename ), args: args ) )!
    }

    private final func loadFile ( filepath: String ) -> String {
        // TODO: error handling..
        let data = try! File.read ( fileDispatcher( filepath ), encoding: NSUTF8StringEncoding )
        return data
    }

    private final func convertSSPtoSwift ( data: String, args: [String:String] ) -> String {
        guard let regex: NSRegularExpression = try? NSRegularExpression ( pattern: "(<%=?)[ \\t\\n]*([\\w\\W]+?)[ \\t\\n]*%>", options: [ .CaseInsensitive ] ) else {
            print ( "Error parsing data." )
            return ""
        }

        var swiftCode: String = ""

        for key in args.keys {
            swiftCode += "var \(key) = \"\(args[key]!)\"\n"
        }

        var startIdx = data.startIndex

        for match in regex.matchesInString ( data, options: [], range: NSMakeRange ( 0, data.length () ) ) {
            let tagRange      = match.rangeAtIndex ( 0 )
            let contentsRange = match.rangeAtIndex ( 2 )
            let swiftTag, htmlTag: String

            if data.substring ( match.rangeAtIndex ( 1 ).location, length: match.rangeAtIndex ( 1 ).length ) == "<%=" {
                swiftTag = "print(\(data.substring ( contentsRange.location, length: contentsRange.length )), terminator:\"\")"
            } else {
                swiftTag = data.substring ( contentsRange.location, length: contentsRange.length )
            }

            htmlTag = data[startIdx ..< data.startIndex.advancedBy ( tagRange.location )]
            .stringByReplacingOccurrencesOfString ( "\"", withString: "\\\"" )
            .stringByReplacingOccurrencesOfString ( "\t", withString: "{@t}" )
            .stringByReplacingOccurrencesOfString ( "\n", withString: "{@n}" )

            swiftCode += "print(\"\(htmlTag)\", terminator:\"\")\n\(swiftTag)\n"

            startIdx = data.startIndex.advancedBy ( tagRange.location + tagRange.length )
        }

        let htmlTag = data[startIdx ..< data.endIndex]
        .stringByReplacingOccurrencesOfString ( "\"", withString: "\\\"" )
        .stringByReplacingOccurrencesOfString ( "\t", withString: "{@t}" )
        .stringByReplacingOccurrencesOfString ( "\n", withString: "{@n}" )

        return (swiftCode + "print(\"\(htmlTag)\")\n")
    }

    private final func compileConvertedSwift ( filename: String, swiftCode: String ) -> String? {
        // TODO: error handling..
        try! File.write ( "\(filename).swift", data: swiftCode, encoding: NSUTF8StringEncoding )

        let compiled: String? = System.executeCmd ( "/usr/bin/swift", args: [ "\(filename).swift" ] )
        .stringByReplacingOccurrencesOfString ( "{@t}", withString: "\t" )
        .stringByReplacingOccurrencesOfString ( "{@n}", withString: "\n" )
        return compiled
    }
    
    private final func fileDispatcher( filepath: String ) -> String {
        if let filename = filepath.componentsSeparatedByString( "/" ).last {
            let nameElement = filename.componentsSeparatedByString( "." )
            if let bundleFilepath = NSBundle.mainBundle().pathForResource( nameElement[0], ofType: nameElement.count > 1 ? nameElement[1] : "" ) {
                return bundleFilepath
            }
        }
        
        // TODO : return error by wrong filename.
        return filepath
    }
}
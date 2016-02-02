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

/**
 A Middleware for compiling a specific SSP(Swift Server Page) file and send the data to client.
 */
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
    
    /**
     Get a compiled result of a SSP(Swift Server Page) file from the specific path.
     
     - Parameter path: The name of the file or path of the file from which to read data.
     
     - Returns: A string initialized by compiled swift server page data from the file specified by path.
     */
    public func render ( path: String ) -> String {
        
        return render( path, args: [:] )
    }
    
    /**
     Get a compiled result of a SSP(Swift Server Page) file from the specific path with input arguments.
     
     - Parameter path: The name of the file or path of the file from which to read data.
     - Parameter args: The arguments which will be using for compiling SSP file.
     
     - Returns: A string initialized by compiled swift server page data from the file specified by path.
     */
    public func render ( path: String, args: [String:String] ) -> String {
        
        guard let data = load ( path ) else {
            return ""
        }
        
        return compile ( path, code: convertToSwift ( from: data, with: args ) )!
    }
    
    /**
     Load the file from input path and convert to String type.
     
     - Parameter path: The name of the file or path of the file from which to read data.
     
     - Returns: A string initialized by data from the file specified by path.
     */
    private final func load ( path: String ) -> String? {
        
        guard let data = File.read ( File.getRealPath( path )) else {
            return nil
        }
        
        guard let str = String( data: data, encoding: NSUTF8StringEncoding ) else {
            return nil
        }
        
        return str
    }
    
    /**
     Get the swift source codes from the specific SSP(Swift Server Page) file. In this process, the SSP codes is divided into HTML codes and swift codes.
     After that, the HTML codes is wrapped by `print` function. An wrapped HTML codes are combined with swift code again.
     
     - Parameter ssp: The original data of SSP file which will be converted to a swift source code file.
     - Parameter args: The list of arguments which is used at compiling.
     
     - Returns: The swift source codes which are converted from SSP file with arguments.
     */
    private final func convertToSwift ( from ssp: String, with args: [String:String] ) -> String {
        guard let regex: NSRegularExpression = try? NSRegularExpression ( pattern: "(<%=?)[ \\t\\n]*([\\w\\W]+?)[ \\t\\n]*%>", options: [ .CaseInsensitive ] ) else {
            print ( "Error parsing data." )
            return ""
        }

        var swiftCode: String = ""

        for key in args.keys {
            swiftCode += "var \(key) = \"\(args[key]!)\"\n"
        }

        var startIdx = ssp.startIndex

        for match in regex.matchesInString ( ssp, options: [], range: NSMakeRange ( 0, ssp.length () ) ) {
            let tagRange      = match.rangeAtIndex ( 0 )
            let contentsRange = match.rangeAtIndex ( 2 )
            let swiftTag, htmlTag: String

            if ssp.substring ( match.rangeAtIndex ( 1 ).location, length: match.rangeAtIndex ( 1 ).length ) == "<%=" {
                swiftTag = "print(\(ssp.substring ( contentsRange.location, length: contentsRange.length )), terminator:\"\")"
            } else {
                swiftTag = ssp.substring ( contentsRange.location, length: contentsRange.length )
            }

            htmlTag = ssp[startIdx ..< ssp.startIndex.advancedBy ( tagRange.location )]
            .stringByReplacingOccurrencesOfString ( "\"", withString: "\\\"" )
            .stringByReplacingOccurrencesOfString ( "\t", withString: "{@t}" )
            .stringByReplacingOccurrencesOfString ( "\n", withString: "{@n}" )

            swiftCode += "print(\"\(htmlTag)\", terminator:\"\")\n\(swiftTag)\n"

            startIdx = ssp.startIndex.advancedBy ( tagRange.location + tagRange.length )
        }

        let htmlTag = ssp[startIdx ..< ssp.endIndex]
        .stringByReplacingOccurrencesOfString ( "\"", withString: "\\\"" )
        .stringByReplacingOccurrencesOfString ( "\t", withString: "{@t}" )
        .stringByReplacingOccurrencesOfString ( "\n", withString: "{@n}" )

        return (swiftCode + "print(\"\(htmlTag)\")\n")
    }
    
    /**
     Get a compiled result of a swift codes.
     
     - Parameter path: The path where compiled swift codes will be locate.
     - Parameter code: Source codes which will be compiled.
     
     - Returns: Compiled data from the swift codes
     */
    private final func compile ( path: String, code: String ) -> String? {
        if !File.write( "\(path).swift", data : code, size: code.characters.count, option: O_TRUNC ) {
            return nil
        } else {
            return System.executeCmd ( "/usr/bin/swift", args: [ "\(path).swift" ] )
                .stringByReplacingOccurrencesOfString ( "{@t}", withString: "\t" )
                .stringByReplacingOccurrencesOfString ( "{@n}", withString: "\n" )
        }
    }
}
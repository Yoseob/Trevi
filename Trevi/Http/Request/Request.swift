//
//  Request.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Request {
    
    // HTTP method like GET, POST.
    public var method: HTTPMethodType = HTTPMethodType.UNDEFINED
    public var version   = String ()
    
    // Original HTTP data include header & body
    public var headerString: String! {
        didSet {
            parse()
        }
    }
    
    // HTTP header
    public var header    = [ String: String ] ()
    
    // HTTP body
    public var body      = [String : AnyObject]()
    
    public var bodyFragments = [String]()
    
    // Body parsed to JSON
    public var json: [String:AnyObject!]!
    
    // Parameter in url for semantic URL
    // ex) /url/:name
    public var params    = [ String: String ] ()
    
    // Qeury string from requested url
    // ex) /url?id="123"
    public var query     = [ String: String ] ()
    
    // Seperated path by component from the requested url
    public var pathComponent: [String] = [ String ] ()
    
    // Requested url
    public var path: String {
        didSet {
            let segment = self.path.componentsSeparatedByString ( "/" )
            for seg in segment {
                pathComponent.append ( seg )
            }
        }
    }
    
    public let startTime: NSDate
    
    // A variable to contain something needs by user.
    public var attribute = [ String : String ] ()
    
    public init () {
        self.path      = String ()
        self.startTime = NSDate ()
    }
    
    public init ( _ headerStr: String ) {
        self.path      = String ()
        self.startTime = NSDate ()
        self.headerString = headerStr
        parse ()
    }
    
    private final func parse () {
        
        // TODO : error when file uploaded..
        guard let converted = headerString else {
            return
        }
        
        let requestHeader: [String] = converted.componentsSeparatedByString ( CRLF )
        let requestLineElements: [String] = requestHeader.first!.componentsSeparatedByString ( SP )
        
        // This is only for HTTP/1.x
        if requestLineElements.count == 3 {
            self.version = requestLineElements[2].stringByReplacingOccurrencesOfString("HTTP/", withString: "")
            if let method = HTTPMethodType ( rawValue: requestLineElements[0] ) {
                self.method = method
            }
            parseUrl( requestLineElements[1] )
            parseHeader( requestHeader )
            
        }
    }
    
    private final func parseUrl ( url: String ) {
        // Parsing request path
        self.path = (url.componentsSeparatedByString( "?" ) as [String])[0]
        if self.path.characters.last != "/" {
            self.path += "/"
        }
        
        // Parsing url query by using regular expression.
        if let regex: NSRegularExpression = try? NSRegularExpression ( pattern: "[&\\?](.+?)=([\(unreserved)\(gen_delims)\\!\\$\\'\\(\\)\\*\\+\\,\\;]*)", options: [ .CaseInsensitive ] ) {
            for match in regex.matchesInString ( url, options: [], range: NSMakeRange( 0, url.length() ) ) {
                let keyRange   = match.rangeAtIndex( 1 )
                let valueRange = match.rangeAtIndex( 2 )
                let key   = url.substring ( keyRange.location, length: keyRange.length )
                let value = url.substring ( valueRange.location, length: valueRange.length )
                self.query.updateValue ( value.stringByRemovingPercentEncoding!, forKey: key.stringByRemovingPercentEncoding! )
            }
        }
    }
    
    private final func parseHeader ( fields: [String] ) {
        for _idx in 1 ..< fields.count {
            if let fieldSet: [String] = fields[_idx].componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                self.header[fieldSet[0].trim()] = fieldSet[1].trim();
            }
        }
    }
    
    public func parseParam ( route: Route ) {
        for params in route.paramsPos {
            self.params.updateValue( pathComponent[ params.1 ], forKey: params.0 )
        }
    }
}
//
//  Request.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Request {
    public var method: HTTPMethodType = HTTPMethodType.UNDEFINED

    // path /test/:id
    public var params                 = [ String: String ] ()

    // path /test?id = "123"
    public var query                  = [ String: String ] ()
    public var header                 = [ String: String ] ()
    
    private var _body: String!
    public var body:   [String:AnyObject!]!

    public var pathComponent: [String] = [ String ] ()
    public var path: String {
        didSet {
            let segment = self.path.componentsSeparatedByString ( "/" )
            for seg in segment {
                pathComponent.append ( seg )
            }
        }
    }
    
    public var data: NSData! {
        didSet {
            parse()
        }
    }

    public init () {
        self.path = String ()
    }
    
    public init ( _ reqData: NSData ) {
        self.path = String ()
        self.data = reqData
        parse ()
    }
    
    private final func parse () {
        let requestHeader: [String] = String ( data: self.data, encoding: NSUTF8StringEncoding )!.componentsSeparatedByString ( CRLF )
        let requestLineElements: [String] = requestHeader.first!.componentsSeparatedByString ( SP )
        
        // This is only for HTTP/1.x
        if requestLineElements.count == 3 {
            if let method = HTTPMethodType ( rawValue: requestLineElements[0] ) {
                self.method = method
            }
            parseUrl( requestLineElements[1] )
            parseHeader( requestHeader )
            self._body = requestHeader.last
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
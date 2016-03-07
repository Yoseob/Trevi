//
//  Request.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

public class Request {
    
    // HTTP method like GET, POST.
    public var method: HTTPMethodType = HTTPMethodType.UNDEFINED
    
    public var httpVersionMajor : String? = "1"
    
    public var httpVersionMinor : String? = "1"
    
    public var version : String {
        return "\(httpVersionMajor).\(httpVersionMinor)"
    }
    
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
            for idx in 0 ..< segment.count where idx != 0 {
                pathComponent.append ( segment[idx] )
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
        parse()
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
            if let method = HTTPMethodType ( rawValue: requestLineElements[0] ) {
                self.method = method
            }
            
            let httpProtocolString = requestLineElements.last!
            let versionComponents: [String] = httpProtocolString.componentsSeparatedByString( "/" )
            let version: [String] = versionComponents.last!.componentsSeparatedByString( "." )
            
            httpVersionMajor = version.first!
            httpVersionMinor = version.last!
            
            parseHeader( requestHeader )
        }
    }
    
    private final func parseHeader ( fields: [String] ) {
        for _idx in 1 ..< fields.count {
            if let fieldSet: [String] = fields[_idx].componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                self.header[fieldSet[0].trim()] = fieldSet[1].trim();
                self.header[fieldSet[0].trim().lowercaseString] = fieldSet[1].trim();
            }
        }
    }
}



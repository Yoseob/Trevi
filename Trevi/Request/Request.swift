//
//  Request.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Request {
    public var requestData: NSData!

    public var method: HTTPMethodType = HTTPMethodType.UNDEFINED

    // path /test/:id
    public var params                 = [ String: String ] ()

    // path /test?id = "123"
    public var query                  = [ String: String ] ()
    public var header                 = [ String: String ] ()
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

    public init () {
        self.path = String ()
    }
    public init ( _ reqData: NSData ) {
        self.path = String ()
        self.requestData = reqData

    }


}
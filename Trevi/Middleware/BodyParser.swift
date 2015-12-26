//
//  BodyParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class BodyParser: Middleware {

    public var name: MiddlewareName;

    public init () {
        name = .BodyParser
    }
    
    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        var req: Request = params.req
        parserBody ( &req )
        return false
    }
    
    public func parserBody ( inout req: Request ) {
        if req.method != HTTPMethodType.GET {
            if let type = req.header["Content-Type"] {
                switch type {
                case "application/json":
                    req.json = self.convertStringToDictionary ( req.body )!
                default:
                    return
                }
            }
        }
    }
    
    private func wrap ( json: [String:AnyObject]! ) {
        
    }
    
    private func convertStringToDictionary ( data: NSData ) -> [String:AnyObject!]! {
        do {
            return try NSJSONSerialization.JSONObjectWithData ( data, options: .MutableContainers ) as? [String:AnyObject!]
        } catch {
            print ( "Something went wrong" )
            return nil
        }
    }
}
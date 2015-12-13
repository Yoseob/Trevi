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
        let r:   Route   = params.route
        parserBody ( &req, r )
        return false
    }

    public func parserBody ( inout req: Request, _ route: Route ) {
        // fill request.params use route.regExp and Params
//        req.body = self.convertStringToDictionary ( headerComp.last! )!
    }

    private func wrap ( json: [String:AnyObject]! ) {

    }

    private func convertStringToDictionary ( text: String ) -> [String:AnyObject!]! {
        if let data = text.dataUsingEncoding ( NSUTF8StringEncoding ) {
            do {
                let json
                = try NSJSONSerialization.JSONObjectWithData ( data, options: .MutableContainers ) as? [String:AnyObject!]
                print ( "convertStringToDictionary" )

                return json
            } catch {
                print ( "Something went wrong" )
            }
        }
        return nil
    }


}
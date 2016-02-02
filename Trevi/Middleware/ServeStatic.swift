//
//  ServeStatic.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 27..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

/**
 A Middleware for serving static files in server like .css, .js, .html, etc.
 */
public class ServeStatic: Middleware {
    
    public var name: MiddlewareName;
    
    public init () {
        name = .ServeStatic
    }
    
    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        let req: Request  = params.req
        let res: Response = params.res
        
        guard let data = File.read( File.getRealPath( req.path ) ) else {
            return false
        }
        
        return res.send( data )
    }
}
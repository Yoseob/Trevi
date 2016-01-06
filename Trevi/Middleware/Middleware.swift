//
//  Middleware.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

// if need handle request, response, route
public typealias MiddlewareParams = ( req:Request, res:Response, route:Route )

public enum MiddlewareName: String {
    case Err             = "error"
    case Undefined       = "undefined"
    case Favicon         = "favicon"
    case BodyParser      = "bodyParser"
    case Logger          = "logger"
    case Json            = "json"
    case CookieParser    = "cookieParser"
    case Session         = "session"
    case SwiftServerPage = "swiftServerPage"
    case Trevi           = "trevi"
    case Router          = "router"
    case ServeStatic     = "serveStatic"
    // else...
}

    /**
    * if you want to make middleware, use this protocol
    *
    * Examples:
    *
    *        public func operateCommand ( params: MiddlewareParams ) -> Bool {
    *           return false
    *        }
    *
    * @public
    */
public protocol Middleware {
    var name: MiddlewareName { get set }
    func operateCommand ( params: MiddlewareParams ) -> Bool
}

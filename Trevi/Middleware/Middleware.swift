//
//  Middleware.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum MiddlewareName: String {
    case Err = "error"
    case Undefined = "undefined"
    case Favicon = "favicon"
    case BodyParser = "bodyParser"
    case Logger = "logger"
    case Json = "json"
    case CookieParser = "cookieParser"
    case Session = "session"
    case SwiftServerPage = "swiftServerPage"
    case Trevi = "trevi"
    case Router = "router"
    // else...
}

public protocol Middleware {
    var name : MiddlewareName {get set} 
    func operateCommand( obj : AnyObject ...)->Bool
}

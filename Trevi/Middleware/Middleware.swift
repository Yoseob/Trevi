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
    case Undefind = "undefind"
    case Favicon = "favicon"
    case BodyParser = "bodyParser"
    case Logger = "logger"
    case Json = "json"
    case CookieParser = "cookieParser"
    case Session = "session"
    case Trevi = "trevi"
    // else...
}

public class Middleware {
    public var name : MiddlewareName!
    public init(){
        
        
        name = .Undefind
    }
    public func operateCommand( obj : AnyObject ...)->Bool{
        return true
    }
    
}
    
//
//  Middleware.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum MiddlewareName: String {
    
    case Err = "Error"
    case Undifind = "Undifind"
    case BodyParser = "bodyParser"
    case Logger = "logger"
    case Json = "json"
    case CookieParser = "cookieParser"
    case Session = "session"
    // else...
}


public class Middleware{
    public var name : MiddlewareName!
    init(){
        name = .Undifind
    }
    
    public func operateCommand( obj : AnyObject ...){
        
    }
    
}
    
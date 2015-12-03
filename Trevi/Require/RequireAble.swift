//
//  RequireAble.swift
//  IWas
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


public enum NameSpace: String {
    
    case Err = "Error"
    case Undifind = "Undefind"
    case BodyParser = "bodyParser"
    case Logger = "logger"
    case Json = "json"
    case CookieParser = "cookieParser"
    case Session = "session"
    // else...
}

typealias requiredHander = (Int) -> (Int)

public protocol RequireAble{

    var name : MiddlewareName! { get }
    func operateCommand( obj : AnyObject ...)
}
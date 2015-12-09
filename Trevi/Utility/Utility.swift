//
//  Utility.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation





public typealias CallBack = (Request , Response) -> Bool // will remove next


public enum HTTPMethodType: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case UNDEFINED = "UNDEFINED"
}

public enum HTTPMethod {
    case Get(CallBack)
    case Post(CallBack)
    case Put(CallBack)
    case Delte(CallBack)
}
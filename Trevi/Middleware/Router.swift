//
//  Router.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Router : Middleware{
    public var name : MiddlewareName
    private var routeTable = [String : Route]()
    public init(){
        name = .Router
    }
   
    public func operateCommand(obj: AnyObject...) -> Bool {
        return true
    }
    
    
    public func appendRoute(path:String , _ route:Route){
        self.routeTable[path] = route
    }
    public func route(path : String) ->Route!{
        return self.routeTable[path]
    }
    
}
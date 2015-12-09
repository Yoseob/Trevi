//
//  MiddlewareManager.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class MiddlewareManager{
    
    public var enabledMiddlwareList = [Any]()
    
    public class func sharedInstance() -> MiddlewareManager {
        dispatch_once(&StaticInstance.dispatchToken) {
            StaticInstance.instance = MiddlewareManager()
        }
        return StaticInstance.instance!
    }
    
    struct StaticInstance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: MiddlewareManager?
    }
    private init(){
        
    }
    
    
    public func handleRequest(request:Request , _ response:Response){
        let containerRoute = Route()
        for middleware in enabledMiddlwareList
        {
            let isNextMd = matchType(middleware, params: request,response,containerRoute)
            if isNextMd == false{
                return
            }
        }
    }
    
    private func matchType(obj : Any , params : Any...) -> Bool{
        let req = params[0] as! Request
        let res = params[1] as! Response
        let route = params[2] as! Route
        var ret : Bool = true;
        switch obj{
        case let mw as Middleware:
            ret = mw.operateCommand(req,res,route)
        case let cb as CallBack:
            ret = cb(req,res)
//        case let ra as RouteAble: break
            //@Todo - create Router and execute route.handler
            //@Todo - RouteAble is unuseful - building time make routing path 
//            ret = ra.executeRequestCallback(req,res)
            
        default:
            break
            
        }
        return ret
    }
    
    public func appendMiddleWare(md : Any){
        enabledMiddlwareList.append(md)
    }
    
    
}

//
//  RouteAble.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//


/*
    RouteAble is not protocol because set,post,update,etc http callback method is not defualt


*/
import Foundation

public class RouteAble{
    private var router = Router()
    public var port : Int
    
     public init(){
        self.port = 8080
    }

    public func handleRequest(req : Request , _ res : Response){
        router.handleRequest(req,response:res)
    }
    
    public func use(middleware : Middleware){
        router.appendMiddleWare(middleware)
    }
    public func use(module : CallBack){
        router.appendRoute(Route(method:.UNDEFINED, path: "err", callback: module))
        //make empty middleware that undefind name, and use empty middleware for error handle or any.
    }
    
    public func get(path : String , _ callback : CallBack ...){
        router.appendRoute(Route(method: .GET, path: path, callback: callback.first!))
    }
    public func get(path : String , _ module : RouteAble ...){
        //
        //        val callbacks = module.setSuperPath(path);
        //        callBacks[path]
    }
    public func post(path : String , _ callback : CallBack ...){
        router.appendRoute(Route(method: .GET, path: path, callback: callback.first!))
    }
    
    public func post(path : String , _ module : RouteAble ...){
        
    }

    
}
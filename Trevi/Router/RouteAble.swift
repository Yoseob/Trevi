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

public class RouteAble {
    public var routeTable = [String : Route]()
    private var router = Router()
    public var port : Int
    
     public  init(){
        self.port = 8080
    }

    
    /**
     * Handle for the given path.
     *
     *
     * @param {Request} req 
     * @param {Response} res
     * @return
     * @public
     */
    public func handleRequest(req : Request , _ res : Response){
        if let route = routeTable[req.path]{
            print(route)
            router.handleRequest(req,response:res)
        }
    }
    
    public func executeRequestCallback(req : Request , _ res : Response){
        for cb in (routeTable[req.path]?.callbacks)!{
            print(cb)
        }
    }
    
    /**
     * Set MiddleWares.
     *
     *
     * @param {Middleware | Callback} middleware
     * @return
     * @public
     */
    public func use(middleware : Any...){
        for md in middleware{
            router.appendMiddleWare(md)
        }
    }
    
    
//    public func use(middleware : Middleware){
//        router.appendMiddleWare(middleware)
//    }
//    public func use(module : CallBack){
//        router.appendRoute(Route(method:.UNDEFINED, path: "err", callback: module))
//        //make empty middleware that undefind name, and use empty middleware for error handle or any.
//    }
//  
    
    
    public func all(path : String , _ callback : CallBack ...) -> RouteAble{
        return self
    }
    
    public func get(path : String , _ callback : CallBack ...) -> RouteAble{
        

        routeTable[path] = Route(method: .GET,path,callback)
        
        return self
    }
    public func get(path : String , _ module : RouteAble ...){
        //
        //        val callbacks = module.setSuperPath(path);
        //        callBacks[path]
    }
    public func post(path : String , _ callback : CallBack ...){
        routeTable[path] = Route(method: .POST,path,callback)

    }
    
    public func post(path : String , _ module : RouteAble ...){
        
    }

    
    
    
}
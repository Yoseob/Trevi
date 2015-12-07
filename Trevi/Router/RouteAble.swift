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


public class RouteAble : Require{
    public var superPath : String?
    
    public var routeTable = [String : Route]()
    
    public var trevi = Trevi.sharedInstance()
    
    //danger this property. i think should be changed private or access controll
    public var middlewareList = [Any]()
    public var port : Int
    public init(){
        self.superPath = ""
        self.port = 8080
    }
    
    public func prepare() {
        //if you want use user custom RouteAble Class for Routing
        // fill prepare func like this
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
    public func handleRequest(req : Request , _ res : Response) ->Bool{
        if let route = routeTable[req.path]{
            print(route)

        }
        return false
    }
    
    public func executeRequestCallback(req : Request , _ res : Response) -> Bool{
        if let rout = routeTable[req.path]{
            for cb in rout.callbacks{
                
                print(cb)
                if cb(req,res) == false{
                    return false
                }
            }
        }
        return true
    }
    
    /**
     * Set Any Type MiddleWares .
     *
     *
     * @param {Middleware | RouteAble} middleware
     * @return
     * @public
     */
    public func use(middleware : Any...){
        for md in middleware{
            middlewareList.append(md)
        }
    }
    /**
     * Set Function Type MiddleWares.
     *
     *
     * @param {Callback} middleware
     * @return
     * @public
     */
    public func use(middleware : CallBack){
        middlewareList.append(middleware)
    }

    /**
    *@deprecate
    */
    public func use(middleware : Method){
        middlewareList.append(middleware)
    }
    
    /**
     * setup static path or url
     * @param {String} sPath
     * @return
     * @public
     */
    public func set(sPath : String){
        
    }

    /**
     * make routing path use preRoutePath
     * @param {String} sPath
     * @return
     * @public
     */
    public func setSuperRoutePath(sPath : String){
        
    }
    
    
    public func all(path : String , _ callback : CallBack ...) -> RouteAble{
        trevi.router.routeTable[superPath! + path] = Route(method:.GET,path,callback)
        return self
    }
    
    public func get(path : String , _ callback : CallBack ...) -> RouteAble{
        trevi.router.routeTable[superPath! + path] = Route(method:.GET,path,callback)
        return self
    }
    public func get(path : String , _ module : RouteAble ...)-> RouteAble{
        for ra in module{
            ra.superPath = (self.superPath)!
            ra.prepare()
        }
        return self
    }
    public func post(path : String , _ callback : CallBack ...){
        trevi.router.routeTable[superPath! + path] = Route(method:.GET,path,callback)

    }
    public func post(path : String , _ module : RouteAble ...)-> RouteAble{
        for ma in module{
            ma.superPath = (self.superPath)! + path
            ma.prepare()
        }
        return self

    }

    
    
    
}
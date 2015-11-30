//
//  Router.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Router {
    private var routeTable = [String : Route]()
    private var enabledMiddlwareTable = [MiddlewareName : Middleware]()
    public required init(){}
   
    func handleRequest(request:Request , response:Response){
        for (_,middleware) in enabledMiddlwareTable{
            if let targetRoute = routeTable[request.path]{
                middleware.operateCommand(request,targetRoute)
                targetRoute.callback[0](request, response){
                    isNext in
                    
                }
            }else{
                //error
                //404 response
                if let targetRoute = routeTable["err"]{
                    targetRoute.callback[0](request, response){
                        isNext in
                        
                    }
                }
            }
        }
    }
    
    func appendMiddleWare(md : Middleware){
        enabledMiddlwareTable[md.name] = md
    }
    
    func appendRoute(route : Route){
        routeTable[route.path] = route
    }
    
}
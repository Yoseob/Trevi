//
//  Route.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Route{
    
    //origin Path
    var path:String!
    //be used Routing
    var routePath:String!
    var method : HTTPMethodType!
    var regExp : String!
    var keys = [String]();
    var callbacks = [CallBack]!()
    var params = [String : String]();
    
    
    init(method : HTTPMethodType , _ path : String ,  _ callback : [CallBack]){
        self.method = method
        self.path = path
        self.callbacks = callback
    }
    init(method : HTTPMethodType , path : String , routeAble : RouteAble...){
        self.method = method
        self.path = path
//        self.callback.append(callback);
    }
    
}
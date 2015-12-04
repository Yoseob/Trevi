//
//  Router.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Router : Middleware{
    private var enabledMiddlwareList = [Any]()
    public required override init(){}
   
    func handleRequest(request:Request , response:Response){
        for middleware in enabledMiddlwareList
        {
            print(middleware)
            let isNextMd = matchType(middleware, params: request,response)
            if isNextMd == false
            {
                break
            }
        }
    }
    
    private func matchType(obj : Any , params : Any...) -> Bool{
        let req = params[0] as! Request

        let res = params[1] as! Response
        var ret : Bool = true;
        switch obj{
        case let mw as Middleware:
            mw.operateCommand(req,res)
        case let cb as CallBack:
            cb(req,res){ b in
                ret = true
            }
        case let ra as RouteAble:
            ra.executeRequestCallback(req,res)
            
        default:
            break
           
        }
        return ret
    }
    
    func appendMiddleWare(md : Any){
        enabledMiddlwareList.append(md)
    }
    
    
}
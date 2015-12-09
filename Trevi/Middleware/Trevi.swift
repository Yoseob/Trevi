//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


public class Trevi : Middleware{
    
    public var usedModuleList = [RouteAble]()
    public var router = Router()
    public var name : MiddlewareName
    
    private init(){
        name = .Trevi
    }
    
    struct StaticInstance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance: Trevi?
    }
    
    public class func sharedInstance() -> Trevi {
        dispatch_once(&StaticInstance.dispatchToken) {
            StaticInstance.instance = Trevi()
        }
        return StaticInstance.instance!
    }
    
    public func store(routeable : RouteAble) -> RouteAble{
        Trevi.sharedInstance().usedModuleList.append(routeable)
        return routeable
    }
    
    public func operateCommand( obj : AnyObject ...)->Bool{
        let req : Request = obj[0] as! Request
        let res : Response = obj[1] as! Response

        if let rout = router.route(req.path){
            print(rout)
            for cb in rout.callbacks{
                
                if cb(req,res) == false{
                    return false
                }
            }
        }
        return true
    }
}
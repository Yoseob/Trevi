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
    
    private override init(){
        super.init()
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
    
    public func trevi(routeable : RouteAble) -> RouteAble{
        Trevi.sharedInstance().usedModuleList.append(routeable)
        return routeable
    }
    
    public override func operateCommand( obj : AnyObject ...)->Bool{
        let req : Request = obj[0] as! Request
        let res : Response = obj[1] as! Response
        router.routeTable[req.path]?.callbacks
        if let rout = router.routeTable[req.path]{
            for cb in rout.callbacks{
                
                print(cb)
                if cb(req,res) == false{
                    return false
                }
            }
        }
        return true
    }
    
    

}
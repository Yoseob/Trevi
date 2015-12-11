//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

<<<<<<< HEAD
//ddd trevi and router relation is unstable
public class Trevi : Middleware{
    
    public var usedModuleList = [RouteAble]()
    public var router = Router()
    public var name : MiddlewareName
    
    private init(){
=======

public class Trevi: Middleware {

    public var usedModuleList = [ RouteAble ] ()
    public var router         = Router ()
    public var name: MiddlewareName

    private init () {
>>>>>>> 3e1e130e7cc0e9dfddb495263cb01ea72bec7848
        name = .Trevi
    }

    struct StaticInstance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance:      Trevi?
    }

    public class func sharedInstance () -> Trevi {
        dispatch_once ( &StaticInstance.dispatchToken ) {
            StaticInstance.instance = Trevi ()
        }
        return StaticInstance.instance!
    }

    public func store ( routeable: RouteAble ) -> RouteAble {
        Trevi.sharedInstance ().usedModuleList.append ( routeable )
        return routeable
    }

    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        let req: Request  = params.req
        let res: Response = params.res
//        let route : Route  = obj[2] as! Route

        if let target = router.route ( req.path ) where target.method == req.method {
            for cb in target.callbacks {

                if cb ( req, res ) == false {
                    return false
                }
            }
        }
        return true
    }
}
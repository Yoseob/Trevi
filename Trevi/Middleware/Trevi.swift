//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

/*
    One of the Middleware class to the path to ensure that able to handle the user defined url
    However, it's not find the path to the running is trevi all save the path at this class when the server is starting on the go.
    This class is real class router's functioning.
*/
public class Trevi: Middleware {

    public var usedModuleList = [ RouteAble ] ()
    public var router         = Router ()
    public var name: MiddlewareName

    private init () {
        name = .Trevi
    }

    //Singleton lazy
    struct StaticInstance {
        static var dispatchToken: dispatch_once_t = 0
        static var instance:      Trevi?
    }

    //instance Singleton
    public class func sharedInstance () -> Trevi {
        dispatch_once ( &StaticInstance.dispatchToken ) {
            StaticInstance.instance = Trevi ()
        }
        return StaticInstance.instance!
    }
    
    /**
     General module to use as a class module used to store, 
     and users and is not necessary.
     
     - Parameter path : User class just a collection of justice url
     
     - Returns : Self
     */
    public func store ( routeable: RouteAble ) -> RouteAble {
        Trevi.sharedInstance ().usedModuleList.append ( routeable )
        return routeable
    }

    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        let req: Request  = params.req
        let res: Response = params.res
        if let target = router.route ( req.path ) where target.method == req.method {
            req.parseParam( target )
            for cb in target.callbacks {
                if cb ( req, res ) == true {
                    return true
                }
            }
        }
        return false
    }
}
//
//  RouteAble.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//


/*
    RouteAble is interface to make module like need to start server and matched for path   
*/

import Foundation


public class RouteAble: Require {

    public var superPath: String?
    public var trevi          = Trevi.sharedInstance ()

    //danger this property. i think should be changed private or access controll
    public var middlewareList = [ Any ] ()
    public var port:      Int
    public init () {
        self.superPath = ""
        self.port = 8080
    }

    public func prepare () {
        //if you want use user custom RouteAble Class for Routing
        // fill prepare func like this
    }

    /**
     * Set middlewares type of function or middleware.
     *
     * if first argument type is string, this function use routing module
     * and then other arguments is RouteAble type.
     * except in this case, anytime use function arguments are Middleware or function(Callback)
     *
     *
     *
     *
     * @param {Middleware | RouteAble | String} middleware
     * @return
     * @public
     */
    public func use (middleware: AnyObject... ) -> RouteAble {
        /*
         * i have no idea which case is better
         * which one is batter? why?
         */
    
        
        //um... how to remove this flow control strategy??
        //I think remove flow control, overring enable to that use("",[AnyObject])
        var temp = middleware
        if case let path as String = temp.first{
            temp.removeFirst ()
            return makeChildRoute (path, module: temp )
        }else if case _ as RouteAble = temp.first{
            return makeChildRoute ("", module: middleware)
        }

        
        for md in middleware {
            middlewareList.append ( md )
        }
        return self
    }

    /**
     * Set Function Type MiddleWares.
     *
     *
     * @param {Callback} middleware
     * @return
     * @public
     */
    public func use ( middleware:CallBack ...)-> RouteAble {
        for md in middleware {
            middlewareList.append ( md )
        }
        return self
    }
    /**
     * Setup static path or url
     * @param {String} sPath
     * @return
     * @public
     */
    public func set ( sPath: String ) {

    }

    /**
     * Make routing path use preRoutePath
     * @param {String} sPath
     * @return
     * @public
     */
    public func setSuperRoutePath ( sPath: String ) {

    }

    public func all ( path: String, _ callback: CallBack... ) -> RouteAble {
        registerCompleteRoutePath ( .GET, path: path, callback: callback )
        return registerCompleteRoutePath ( .POST, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func get ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .GET, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func post ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .POST, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func put ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .PUT, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func head ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .HEAD, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func delete ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .DELETE, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1. but we not support this version
     */
    public func options(){}
    /**
     * Support http ver 1.1. but we not support this version
     */
    public func trace(){}
    /**
     * Support http ver 1.1. but we not support this version
     */
    public func connect(){}
    /**
     * Support http ver 1.1. but we not support this version
     */
    public func link(){}
    
    /**
     * Support http ver 1.1. but we not support this version
     */
    public func unlink(){}
    

    public func makeChildRoute ( path: String, module: [AnyObject] ) -> RouteAble {
        let _ = module.map({ (obj) -> RouteAble in
            let ma = (obj as! RouteAble)
            ma.superPath = (self.superPath)! + path
            ma.prepare ()
            return ma
        })
        return self
    }

    private func registerCompleteRoutePath ( type: HTTPMethodType, path: String, callback: [CallBack] ) -> RouteAble {
        var completePath = superPath! + path;
        if superPath != "" && path == "/" {
            completePath = superPath!
        }
        trevi.router.appendRoute ( completePath, Route ( method: type, completePath, callback ) );
        return self
    }
}
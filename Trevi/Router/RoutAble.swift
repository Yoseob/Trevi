//
//  RoutAble.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//


/*
    RoutAble is interface to make module like need to start server and matched for path   
*/

import Foundation


public class RoutAble: Require {

    public var superPath: String? = ""
    public var router = Router.sharedInstance()
    public var eventListener : EventListener?

    //danger this property. i think should be changed private or access controll
    public var middlewareList = [ Any ] ()
    public var port:      Int
    public init () {
        self.superPath = ""
        self.port = 8080
    }

    public func prepare () {
        //if you want use user custom RoutAble Class for Routing
        // fill prepare func like this
    }

    /**
     * Set middlewares type of function or middleware.
     *
     * if first argument type is string, this function use routing module
     * and then other arguments is RoutAble type.
     * except in this case, anytime use function arguments are Middleware or function(Callback)
     *
     *
     *
     *
     * @param { RoutAble | String} middleware
     * @return
     * @public
     */
    public func use (var path : String = "" ,  _ module : RoutAble... ) -> RoutAble {
        if path == "/"{
            path = ""
        }
        return makeChildsRoute (path, module: module )
    }
    /**
     * Set middlewares type of function or middleware.
     *
     * if first argument type is string, this function use routing module
     * and then other arguments is RoutAble type.
     * except in this case, anytime use function arguments are Middleware or function(Callback)
     *
     *
     *
     *
     * @param { RoutAble | String} middleware
     * @return
     * @public
     */
    public func use (middleware: Middleware... ) -> RoutAble {
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
    public func use ( middleware:CallBack ...)-> RoutAble {
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

    public func all ( path: String, _ callback: CallBack... ) -> RoutAble {
        registerCompleteRoutePath ( .GET, path: path, callback: callback )
        return registerCompleteRoutePath ( .POST, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func get ( path: String, _ callback: CallBack... ) -> RoutAble {
        return registerCompleteRoutePath ( .GET, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func post ( path: String, _ callback: CallBack... ) -> RoutAble {
        return registerCompleteRoutePath ( .POST, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func put ( path: String, _ callback: CallBack... ) -> RoutAble {
        return registerCompleteRoutePath ( .PUT, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func head ( path: String, _ callback: CallBack... ) -> RoutAble {
        return registerCompleteRoutePath ( .HEAD, path: path, callback: callback )
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func delete ( path: String, _ callback: CallBack... ) -> RoutAble {
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
    

    //wille deprecate
    public func makeChildsRoute ( path: String, module: [AnyObject] ) -> RoutAble {
        let _ = module.map({ (obj) -> RoutAble in
            let ma = (obj as! RoutAble)
            ma.superPath = (self.superPath)! + path
            ma.prepare ()
            return ma
        })
        return self
    }

    public func makeChildRoute ( path: String, module: AnyObject ) -> RoutAble {
        let ma = (module as! RoutAble)
        ma.superPath = (self.superPath)! + path
        ma.prepare ()
        return ma
    }

    
    private func registerCompleteRoutePath ( type: HTTPMethodType, path: String, callback: [CallBack] ) -> RoutAble {
        var completePath = superPath! + path;
        if superPath != "" && path == "/" {
            completePath = superPath!
        }
        router.appendRoute ( completePath, Route ( method: type, completePath, callback ) );
        return self
    }
}

extension RoutAble{
    /**
     *
     * Handling request and operate middleware stacked in(at?) list
     * if matched suitable module or middleware, that should return false to stop operate next thing
     *
     *
     * @param {Request} request
     * @param {Response} response
     * @public
     */
    public func handleRequest ( request: Request, _ response: Response ) {
        let containerRoute = Route ()
        for middleware in middlewareList {
            let isNextMd = matchType ( middleware, params: MiddlewareParams ( request, response, containerRoute ) )
            if isNextMd == true {
                return
            }
        }
    }
    
    /**
     *
     * Operate after matching type of module
     *
     *
     * @param {Any | Middleware | CallBack} obj
     * @param {MiddlewareParams} params
     * @public
     */
    private func matchType ( obj: Any, params: MiddlewareParams ) -> Bool {
        
        
        var ret: Bool = false;
        switch obj {
        case let mw as Middleware:
            ret = mw.operateCommand ( params )
        case let cb as CallBack:
            ret = cb ( params.req, params.res )
        default:
            break
            
        }
        return ret
    }

}
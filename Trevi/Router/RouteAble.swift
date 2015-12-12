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


public class RouteAble: Require {

    public var superPath: String?
    public var routeTable     = [ String: Route ] ()
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
    public func use ( middleware: Any... ) {
        var temp = middleware

        /*
         * i have no idea which case is better
         * which one is batter? why?
         */
        if true {
            if case let path as String = temp.first{
                temp.removeFirst ()
                let routeList = [ RouteAble ] ( temp )
                makeChildRoute ( path, module: routeList )
                return
            }else if case let route as RouteAble = temp.first{
                let routeList = [ RouteAble ] ( temp )
                makeChildRoute ( "", module: routeList )
                return
            }
            for md in middleware {
                middlewareList.append ( md )
            }
        } else {
            /*
            switch temp.first{
            case let path as String:
                temp.removeFirst()
                let routeList = [RouteAble](temp)
                makeChildRoute(path, module:routeList)
            default:
                for md in middleware{
                    middlewareList.append(md)
                }
                break
            }
            */
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
    public func use ( middleware: CallBack ) {
        middlewareList.append ( middleware )
    }

    /**
     * setup static path or url
     * @param {String} sPath
     * @return
     * @public
     */
    public func set ( sPath: String ) {

    }

    /**
     * make routing path use preRoutePath
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

    public func get ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .GET, path: path, callback: callback )
    }

    public func post ( path: String, _ callback: CallBack... ) -> RouteAble {
        return registerCompleteRoutePath ( .POST, path: path, callback: callback )
    }

    public func makeChildRoute ( path: String, module: [RouteAble] ) -> RouteAble {
        for ma in module {
            ma.superPath = (self.superPath)! + path
            ma.prepare ()
        }
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
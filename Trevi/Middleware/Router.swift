//
//  Router.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


/*
    One of the Middleware class to the path to ensure that able to handle the user defined url
    However, it's not find the path to the running is trevi all save the path at this class when the server is starting on the go.
    so it is like lazyRouter

*/
public class Router: Middleware {

    public var  name: MiddlewareName
    public var routeList = [ Route ] ()

    public init () {
        name = .Router
    }

    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        return false
    }
    
    /**
     To us to add user-defined url and priority changes.
     
     - Parameter path: User-defined url
     
     - Returns: Void
     */
    public func appendRoute ( path: String, _ route: Route ) {
        self.routeList.append( route )
        sortRouteList()
    }

    // TODO : why can't get path parameter...?
    public func route ( path: String ) -> Route! {
        for route in routeList {
            if path.isMatch( route.regex ) {
                return route
            }
        }
        return nil
    }
    
    // Priority for the spirits.
    private func sortRouteList() {
        routeList = routeList.sort( { $0.regex > $1.regex } )
    }
}
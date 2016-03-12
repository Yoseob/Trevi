//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public typealias HttpCallback = ( ( IncomingMessage, ServerResponse, NextCallback?) -> Void )

public typealias NextCallback = ()->()

public typealias ReceivedParams = (buffer: UnsafeMutablePointer<CChar>, length: Int)


/*
    This protocol is to other external module on the server should be implemented.
    Currently, the Trevi is it used to be implemented this.

*/
public protocol ApplicationProtocol {
    func createApplication() -> Any
}

public class Http {
    
    public init () {
        
    }
    
    /**
     * Create Server base on RouteAble Model, maybe it able to use many Middleware
     * end return self
     *
     * Examples:
     *     http.createServer(RouteAble).listen(Port)
     *
     *
     *
     * @param {RouteAble} requireModule
     * @return {Http} self
     * @public
     */

    //Only one function of registration is available.
    public func createServer( requestListener: ( IncomingMessage, ServerResponse, NextCallback? )->()) -> Net{
        let server = HttpServer(requestListener: requestListener)
        return server
    }
    
    //Can be saved using external module.
    public func createServer( requestListener: Any) -> Net{
        let server = HttpServer(requestListener: requestListener)
        return server
    }
   
}


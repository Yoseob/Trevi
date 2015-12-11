//
//  Server.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


let CurrentSocket: Void -> SocketServer = {
    return SwiftSocketServer ()
}

public class Http {
<<<<<<< HEAD
    
    private var socket: SocketServer = CurrentSocket()
    private var mwManager = MiddlewareManager.sharedInstance()
    public init(){
        
=======

    private var socket: SocketServer = CurrentSocket ()
    private var mwManager            = MiddlewareManager.sharedInstance ()
    private var router               = Router ()

    public init () {

>>>>>>> 3e1e130e7cc0e9dfddb495263cb01ea72bec7848
    }

    public func createServer ( requireModule: Any... ) -> Http {

        for rm in requireModule {
            switch rm {
<<<<<<< HEAD
            case let module as RouteAble :
=======
            case let module as RouteAble:
                makeRoutPath ( module )
>>>>>>> 3e1e130e7cc0e9dfddb495263cb01ea72bec7848
                mwManager.enabledMiddlwareList = module.middlewareList;
            case let callback as CallBack:
                mwManager.enabledMiddlwareList.append ( callback )
            default: break
            }
        }

        socket.receivedRequestCallback = {
<<<<<<< HEAD
            req,res,sock in
            self.mwManager.handleRequest(req,res)
=======
            req, res, sock in
            self.mwManager.handleRequest ( req, res )
//            whill change this func
//            self.mwManager.handleRequest(req,res,router)
>>>>>>> 3e1e130e7cc0e9dfddb495263cb01ea72bec7848
            return false
        }
        return self
    }

    public func listen ( port: Int ) throws {
        try socket.startOnPort ( port )

        if true {

            while true {

                NSRunLoop.mainRunLoop ().run ()
            }
        }
    }

    public func stopListening () {
        socket.disconnect ()
    }
<<<<<<< HEAD
    
=======

    //for make full Routing Path, use iterating method save Router????????
    private func makeRoutPath ( module: RouteAble ) {

    }
>>>>>>> 3e1e130e7cc0e9dfddb495263cb01ea72bec7848
}

//
//  Http.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Http {

    private var socket = TreviSocketServer ()
    private var mwManager            = MiddlewareManager.sharedInstance ()


    public init () {
    }

    public func createServer ( requireModule: RouteAble... ) -> Http {
        
        for rm in requireModule {
            rm.makeChildRoute("", module:requireModule)
            mwManager.enabledMiddlwareList += rm.middlewareList;
        }
        receivedRequestCallback();
        return self
    }
    
    public func createServer ( callBacks: CallBack... ) -> Http {
        for cb in callBacks {
            mwManager.enabledMiddlwareList.append ( cb )
        }
        receivedRequestCallback();
        return self
    }
    
    private func receivedRequestCallback() {
        socket.httpCallback = {
            req,res,sock in
            self.mwManager.handleRequest(req,res)
            
            return false
        }
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

}

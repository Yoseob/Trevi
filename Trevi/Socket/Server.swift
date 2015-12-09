//
//  Server.swift
//  IWAS
//
//  Created by LeeYoseob on 2015. 11. 20..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


let CurrentSocket: Void -> SocketServer = {
    return SwiftSocketServer()
}

public class Server {
    
    private var socket: SocketServer = CurrentSocket()
    private var mwManager = MiddlewareManager.sharedInstance()
    private var router = Router()

    public init(){
        
    }

    public func createServer(requireModule:Any...) -> Server{
        
        for rm in requireModule{
            switch rm {
            case let module as RouteAble :
                makeRoutPath(module)
                mwManager.enabledMiddlwareList = module.middlewareList;
            case let callback as CallBack :
                mwManager.enabledMiddlwareList.append(callback)
            default: break
            }
        }
        
        socket.receivedRequestCallback = {
            req,res,sock in
            self.mwManager.handleRequest(req,res)
//            whill change this func
//            self.mwManager.handleRequest(req,res,router)
            return false
        }
        return self
    }

    public func listen(port : Int)throws{
        try socket.startOnPort(port)
        
        if true {
            
            while true {
                
                NSRunLoop.mainRunLoop().run()
            }
        }
    }

    public func stopListening() {
        socket.disconnect()
    }
    
    //for make full Routing Path, use iterating method save Router????????
    private func makeRoutPath(module : RouteAble){

    }
}

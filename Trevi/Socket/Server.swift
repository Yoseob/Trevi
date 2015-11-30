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
    private var router = Router()

    
    public init(){
    }
    
    public func serveHTTP(port p: Int) throws {
        
        socket.receivedRequestCallback = {
            request,response,socket in
            self.handleRequest(socket, request , response)
            return true
        }
        try socket.startOnPort(p)
        
        if true {
            
            while true {
            
                NSRunLoop.mainRunLoop().run()
            }
        }
    }
    
    private func handleRequest(socket:Socket, _ req : Request , _ res : Response){
        router.handleRequest(req,response:res)
    }

    public func stopListening() {
        socket.disconnect()
    }
    
    public func use(middleware : Middleware){
        router.appendMiddleWare(middleware)
    }
    public func use(module : CallBack){
        router.appendRoute(Route(method:.UNDEFINED, path: "err", callback: module))
    }

    public func get(path : String , _ callback : CallBack ...){
        router.appendRoute(Route(method: .GET, path: path, callback: callback.first!))
    }
    public func get(path : String , _ module : RouteAble ...){
//
//        val callbacks = module.setSuperPath(path);
//        callBacks[path]
    }
    public func post(path : String , _ callback : CallBack ...){
        router.appendRoute(Route(method: .GET, path: path, callback: callback.first!))
    }
    
    public func post(path : String , _ module : RouteAble ...){
        
    }
    

    
 
    
    
}

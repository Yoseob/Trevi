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

public enum Handler{
    case Send
    case Next
}

public typealias CallBack = (Request , Response) -> Handler

public class Server {
    
    private var socket: SocketServer = CurrentSocket()

    
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
        
        let msg = "hello iwas"
        print(req.path)
        res.sender(msg)

    }
    
    
    
    
    public func stopListening() {
        
        socket.disconnect()
    }
    
    public func get(path : String , _ callback : CallBack){
        
    }
    public func get(path : String , _ module : RequireAble){
//
//        val callbacks = module.setSuperPath(path);
//        callBacks[path]
    }
    public func post(path : String , _ callback : CallBack){
        
    }
    public func post(path : String , _ module : RequireAble){
        
    }
    
 
    
    
}

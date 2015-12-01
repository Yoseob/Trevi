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


    
    public init(){
    }
    

    public func createServer(module:RouteAble) throws {
        
        socket.receivedRequestCallback = {
            request,response,socket in
            module.handleRequest(request , response)
            return true
        }
        try socket.startOnPort(module.port)
        
        if true {
            
            while true {
                
                NSRunLoop.mainRunLoop().run()
            }
        }
    }

    public func stopListening() {
        socket.disconnect()
    }
    
      

    
 
    
    
}

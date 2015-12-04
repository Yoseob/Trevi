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
    

    public func createServer(requireModule:Any...) -> Server{
        
        socket.receivedRequestCallback = {
            request,response,socket in
            for rm in requireModule{
                switch rm {
                case let module as RouteAble :
                    
                    module.handleRequest(request , response)
                    
                case let cb as CallBack :
                    
                    cb(request,response){ next in
                        if !next {
                            return
                        }
                    }
                default: break
                }
            }
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
    


    
 
    
    
}

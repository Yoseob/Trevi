//
//  NetEchoServer.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 3..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public class NetEchoServer : Net {
    
    public init(){
        
        super.init()
        self.on("connection", connectionListener)
    }
    
    public override func listen(port: Int32) -> Int32? {
        
//        print("Main thread : \(getThreadID())")
        print("Echo Server starts ip : \(ip), port : \(port).")
        
        guard let _ = super.listen(port) else {
            return nil
        }
        
        return 0
    }
    
    
    func connectionListener(sock: AnyObject){
        
        let socket = sock as! Socket
        
        
//        let addressInfo = Tcp.getPeerName(uv_tcp_ptr(socket.handle))
//        let (ip, port) = getEndpointFromSocketAddress(addressInfo)!
//        print("New client!  ip : \(ip), port : \(port).")
//        print("Connect thread : \(getThreadID())")
        
        socket.ondata = { data, nread in
            
//            print("Read thread : \(getThreadID())")
//            print("Read length: \(nread)")
            socket.write(data, handle: socket.handle)
        }
        
        socket.onend = {
//            print("Close thread : \(getThreadID())")
        }
        
//        let fileserver = FileServer()
//        fileserver.fileTestStart()
    }
    
}

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
    
    public override func listen(port: Int32) {
        
        //        fileStreamTest("/Users/Ingyure/Documents/fstest.txt")
        
        print("Echo Server starts ip : \(ip), port : \(port).")
        //        print("Main thread : \(getThreadID())")
        super.listen(port)
        
    }
    
    
    func connectionListener(sock: AnyObject){
        
        let socket = sock as! Socket
        
//        print("Connect thread : \(getThreadID())")
        
        socket.ondata = { data, nread in
            
//            print("Read thread : \(getThreadID())")
//            print("Read length: \(nread)")
            socket.write(data, handle: socket.handle)
        }
        
        socket.onend = {
            //            print("Close thread : \(getThreadID())")
        }
    }
    
}

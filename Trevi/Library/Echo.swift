//
//  Echo.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 24..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv

public class Echo : Net {
    
    public init(){
        
        super.init()
        self.on("connection", connectionListener)
    }
    
    public override func listen(port: Int32) {
        
        print("Echo Server starts ip : \(ip), port : \(port).")
        print("Main thread : \(getThreadID())")
        super.listen(port)
    }
    
    
    func connectionListener(sock: AnyObject){
        
        let socket = sock as! Socket
        
        print("Connect thread : \(getThreadID())")
        
        socket.ondata = { buf, nread in
            
            print("Read thread : \(getThreadID())")
            print(nread)
            
            let data = NSData(bytesNoCopy: buf.memory.base, length: nread)
            
            print(blockToString(buf.memory.base, length : nread-2))
            
            socket.write(data, handle: socket.handle)
            
        }
        
        socket.onend = {}
    }
    
}


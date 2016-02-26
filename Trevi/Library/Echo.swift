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
        
        filetest()
        
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
        
        socket.onend = {
            print("Close thread : \(getThreadID())")
        }
    }
    
}

func filetest(){
    
    let fs : FsBase = FsBase()
    
    fs.events[UV_FS_OPEN] = {
        request in

        FsBase.read(request)
    }
    
    fs.events[UV_FS_READ] = { request in
        
        let buffer = uv_buf_ptr(request.memory.data)
        let length = request.memory.result
        
        print("Read length : \(length)")
        print(blockToString(buffer.memory.base, length: length))
        
        FsBase.cleanup(request)
    }
    
    FsBase.open(fs.fsRequest, path: "/Users/Ingyure/Documents/fstest.txt")
}
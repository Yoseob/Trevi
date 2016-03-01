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
        
//        fileStreamTest("/Users/Ingyure/Documents/fstest.txt")
        
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



func fileStreamTest(path : String){
    
    let filePipe = Pipe()
    
    filePipe.event.onRead = { (handle, nread, buffer) in
        
        print(nread)
        
        let infoPtr = UnsafeMutablePointer<FsBase.Info>(handle.memory.data)
        
        infoPtr.memory.nread += nread
        
        if infoPtr.memory.nread == Int(infoPtr.memory.size) {
            
            FsBase.close(infoPtr.memory.request)
            Handle.close(uv_handle_ptr(handle))
        }
        
        if buffer.memory.len > 0 {
            
            //            let writeHandle = Pipe()
            //            FsBase.streamWriteFile(writeHandle.pipeHandle, buffer: buffer, path: "/Users/Ingyure/Documents/fswritetest.txt")
            print(blockToString(buffer.memory.base, length: nread))
            
            buffer.memory.base.dealloc(buffer.memory.len)
        }
        
    }
    
    filePipe.event.onClose = { (handle) in
        print("File pipe cloesing")
        
    }
    
    FsBase.streamReadFile(filePipe.pipeHandle, path: path)
    
}


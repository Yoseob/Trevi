//
//  Net.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 20..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

var ClientSocketArchiver = [uv_stream_ptr: Socket]()


public class Socket: EventEmitter{ // should be inherited stream, eventEmitter
    public var handle: uv_stream_ptr!
    public var ondata: (( uv_buf_const_ptr, Int )->Void)?
    public var onend: ((Void)->(Void))?
    
    public init(handle: uv_stream_ptr){
        self.handle = handle
    }
    
    public func close(){
        Handle.close(uv_handle_ptr(handle))
    }
}


func onConnection(handle : uv_stream_ptr , _ EE: EventEmitter) {
//    let addressInfo = Tcp.getPeerName(uv_tcp_ptr(handle))
//    let (ip, port) = getEndpointFromSocketAddress(addressInfo)!
    
    let socket = Socket(handle: handle)
    ClientSocketArchiver[handle] = socket
    EE.emit("connection", socket)
//    print("New client!  ip : \(ip), port : \(port).")
}

func onRead(handle : uv_stream_ptr, nread: Int, bufs: uv_buf_const_ptr) -> Void {
    let socket = ClientSocketArchiver[handle]
    socket?.ondata!(bufs,nread)

}


func write(string: String, handle : uv_stream_ptr) {
    let req : uv_write_ptr = uv_write_ptr.alloc(1)
    if let cString = string.cStringUsingEncoding(NSUTF8StringEncoding) {
        let buf = UnsafeMutablePointer<uv_buf_t>.alloc(1)
        buf.memory = uv_buf_init(UnsafeMutablePointer<Int8>(cString), UInt32(cString.count))
        uv_write(req, handle, UnsafePointer<uv_buf_t>(buf), 1, writeAfter)
    }
}

func onClose(handle : uv_handle_ptr) {
    print("Client closed.")
    let socket = ClientSocketArchiver[uv_stream_ptr(handle)]
    ClientSocketArchiver.removeValueForKey(uv_stream_ptr(handle))
    socket!.onend!()

}





public class Net: EventEmitter {
    
    let ip : String
    var port : Int32
    
    let server : Tcp
    
    
    public init(ip : String = "127.0.0.1") {
        self.ip = ip
        self.port = 8080
        self.server = Tcp()
    }
    
   
    public func listen(port: Int32){
        self.port = port
        
        self.emit("listening")
        
        self.server.event.onConnection = { client in
            
            onConnection(client, self)
            // Set client event
            if let wrap = Handle.dictionary[uv_handle_ptr(client)] {
                
                wrap.event.onRead = onRead
                wrap.event.onClose = onClose
            }
        }
        
        Tcp.bind(self.server.tcpHandle, address : self.ip, port: self.port)
        
        Tcp.listen(uv_stream_ptr(self.server.tcpHandle))
    
        uv_run(uv_default_loop(), UV_RUN_DEFAULT)
    }
    
}
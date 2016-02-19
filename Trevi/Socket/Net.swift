//
//  Net.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 20..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

func onConnection(handle : uv_stream_ptr) {
    let addressInfo = Tcp.getPeerName(uv_tcp_ptr(handle))
    let (ip, port) = getEndpointFromSocketAddress(addressInfo)!
    
    print("New client!  ip : \(ip), port : \(port).")
}

func onRead(handle : uv_stream_ptr, nread: Int, bufs: uv_buf_const_ptr) -> Void {
    print("echo_read: start, nread: \(nread)")
    
    
    print(blockToString(bufs.memory.base, length: nread))
    
    Tcp.doWrite(bufs, count: UInt32(nread), sendHandle: handle)
    
}

func onClose(handle : uv_handle_ptr) {
    
    print("Client closed.")
}

public class Net {
    
    let ip : String
    let port : Int32
    
    let server : Tcp
    
    
    public init(ip : String = "127.0.0.1", port : Int32) {
        self.ip = ip
        self.port = port
        self.server = Tcp()
    }
    
    public func startServer() -> Bool {
        
        self.server.event.onConnection = { client in
            
            onConnection(client)
            
            // Set client event
            if let wrap = Handle.dictionary[uv_handle_ptr(client)] {
                
                wrap.event.onRead = onRead
                wrap.event.onClose = onClose
            }
        }
        
        Tcp.bind(self.server.tcpHandle, address : self.ip, port: self.port)
        
        Tcp.listen(uv_stream_ptr(self.server.tcpHandle))
        
        
        let addressInfo = Tcp.getSocketName(self.server.tcpHandle)
        let (ip, port) = getEndpointFromSocketAddress(addressInfo)!
        
        print("Http Server starts ip : \(ip), port : \(port).")
        
        uv_run(uv_default_loop(), UV_RUN_DEFAULT)
        
        return true
    }
    
}
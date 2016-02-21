//
//  Net.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 20..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

var ClientSocketArchiver = [uv_stream_ptr: TestClientSocket]()


public class TestClientSocket: EventEmitter{ // should be inherited stream, eventEmitter
    public var handle: uv_stream_ptr!
    public var ondata: (( uv_buf_const_ptr, Int )->Void)?
    public init(handle : uv_stream_ptr){
        self.handle = handle
    }
    
}


func onConnection(handle : uv_stream_ptr) {
    let addressInfo = Tcp.getPeerName(uv_tcp_ptr(handle))
    let (ip, port) = getEndpointFromSocketAddress(addressInfo)!
    
    print("New client!  ip : \(ip), port : \(port).")
}

func onRead(handle : uv_stream_ptr, nread: Int, bufs: uv_buf_const_ptr) -> Void {

    
    let socket = ClientSocketArchiver[handle]
    socket?.ondata!(bufs,nread)
//    print(blockToString(bufs.memory.base, length: nread))
//    let result = "123123123"
//    if let cString = result.cStringUsingEncoding(NSUTF8StringEncoding) {
//        let buf = UnsafeMutablePointer<uv_buf_t>.alloc(1)
//        buf.memory = uv_buf_init(UnsafeMutablePointer<Int8>(cString), UInt32(cString.count))
//
//    }
//        Tcp.doWrite(bufs, count: UInt32(nread), sendHandle: handle)
//    
//    
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
//    ClientSocketArchiver.removeValueForKey(<#T##key: Hashable##Hashable#>)
    //remove what
    print("Client closed.")
    
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
    
    
    public func close(){
        
    }
    
    public func listen(port: Int32){
        self.port = port
        self.server.event.onConnection = { client in
            
            onConnection(client)
            
            
            let socket = TestClientSocket(handle: client)
            ClientSocketArchiver[client] = socket
            self.emit("connection", socket)
            
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
        

    }
    
}
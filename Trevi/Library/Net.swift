//
//  Net.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 20..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


public class Socket: EventEmitter { // should be inherited stream, eventEmitter
    
    public static var dictionary = [uv_stream_ptr : Socket]()
    
    public var handle: uv_stream_ptr!
    public var ondata: (( uv_buf_const_ptr, Int )->Void)?
    public var onend: ((Void)->(Void))?
    
    public init(handle: uv_stream_ptr) {
        self.handle = handle
        super.init()
        Socket.dictionary[handle] = self
        
        print("socket init")
    }
    deinit{
        print("socket deinit")
    }
    
    
    func write(data: NSData, handle : uv_stream_ptr) {
 
        // Should add buffer module.
        let buffer = uv_buf_ptr.alloc(1)
        buffer.memory = uv_buf_init(UnsafeMutablePointer<Int8>(data.bytes), UInt32(data.length))
        
        Stream.doWrite(uv_buf_const_ptr(buffer), handle: handle)
        
//        self.setTimeout(100){_ in 
//            self.close()
//        }
    }
    
    public func close() {
        
        Socket.dictionary[self.handle] = nil
        Handle.close(uv_handle_ptr(handle))
    }
    
    public func setTimeout( msecs : UInt64, callback : ((uv_timer_ptr)->()) ) {
        
        let timer : Timer = Timer()
        timer.event.onTimeout = callback
        Timer.start(timer.timerhandle, timeout: msecs, count: 0)
    }
    
    public func setKeepAlive(msecs: UInt32) {
        
        Tcp.setKeepAlive(uv_tcp_ptr(self.handle), enable: 1, delay: msecs)
    }
    
}


// Socket static functions.

extension Socket {

    public static func onConnection(handle : uv_stream_ptr , _ EE: EventEmitter) {
    //    let addressInfo = Tcp.getPeerName(uv_tcp_ptr(handle))
    //    let (ip, port) = getEndpointFromSocketAddress(addressInfo)!
    //    print("New client!  ip : \(ip), port : \(port).")
        
        let socket = Socket(handle: handle)
        
        EE.emit("connection", socket)
        
    }

    public static func onRead(handle : uv_stream_ptr, nread: Int, bufs: uv_buf_const_ptr) -> Void {
        
        if let wrap = Socket.dictionary[handle] {
            wrap.ondata!(bufs,nread)
        }
    }

    public static func onClose(handle : uv_handle_ptr) {
        print("onClose called")
        
        if let wrap = Socket.dictionary[uv_stream_ptr(handle)] {
     
            Socket.dictionary.removeValueForKey(uv_stream_ptr(handle))
            wrap.onend!()
        }
    }
        
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
    
   
    public func listen(port: Int32) {
        self.port = port
        
        self.emit("listening")
        
        self.server.event.onConnection = { client in
            
            Socket.onConnection(client, self)
            
            // Set client event
            if let wrap = Handle.dictionary[uv_handle_ptr(client)] {
                
                wrap.event.onRead = Socket.onRead
                wrap.event.onClose = Socket.onClose
            }
        }
        
        Tcp.bind(self.server.tcpHandle, address : self.ip, port: self.port)
        
        Tcp.listen(self.server.tcpHandle)
    
        uv_run(uv_default_loop(), UV_RUN_DEFAULT)
    }
    
}
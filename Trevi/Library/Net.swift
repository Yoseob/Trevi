//
//  Net.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 20..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public class Socket: EventEmitter { // should be inherited stream, eventEmitter
    
    public static var dictionary = [uv_stream_ptr : Socket]()
    
    public var handle: uv_stream_ptr!
    public var ondata: (( NSData, Int )->Void)?
    public var onend: ((Void)->(Void))?
    
    public init(handle: uv_stream_ptr) {
        self.handle = handle
        super.init()
        Socket.dictionary[handle] = self
        
    }
    
    func write(data: NSData, handle : uv_stream_ptr) {
 
        // Should add buffer module.
        
        Stream.doWrite(data, handle: handle)
    }
    
    public func close() {
    
        Handle.close(uv_handle_ptr(handle))
    }
    
    public func setKeepAlive(msecs: UInt32) {
        
        Tcp.setKeepAlive(uv_tcp_ptr(self.handle), enable: 1, delay: msecs)
    }
    
}


// Socket static functions.

extension Socket {

    public static func onConnection(handle : uv_stream_ptr , _ EE: EventEmitter) {
        
        let socket = Socket(handle: handle)
        EE.emit("connection", socket)
    }

    public static func onRead(handle : uv_stream_ptr, data: NSData) -> Void {
        
        if let wrap = Socket.dictionary[handle] {
            wrap.ondata!(data, data.length)
        }
    }
    
    public static func onAfterWrite(handle: uv_stream_ptr) -> Void {
      
//        Socket.onTimeout(100){
//            _ in
//            Handle.close(uv_handle_ptr(handle))
//        }
    }

    public static func onClose(handle : uv_handle_ptr) {
        
        if let wrap = Socket.dictionary[uv_stream_ptr(handle)] {
            wrap.onend!()
            wrap.events.removeAll()
            wrap.ondata = nil
            wrap.onend = nil
            Socket.dictionary.removeValueForKey(uv_stream_ptr(handle))
        }
    }
    
    public static func onTimeout( msecs : UInt64, callback : ((uv_timer_ptr)->()) ) {
        
        let timer : Timer = Timer()
        timer.event.onTimeout = callback
        Timer.start(timer.timerhandle, timeout: msecs, count: 0)
    }
        
}


public class Net: EventEmitter {
    
    let ip : String
    var port : Int32
    
    let server : Tcp
    
    public init(ip : String = "0.0.0.0") {
        self.ip = ip
        self.port = 8080
        self.server = Tcp()
    }
    
   
    public func listen(port: Int32) {
        self.port = port
        
        self.emit("listening")
        
        self.server.event.onConnection = { 
            client in
            
            Socket.onConnection(client, self)
            
            // Set client event
            if let wrap = Handle.dictionary[uv_handle_ptr(client)] {
                
                wrap.event.onRead = Socket.onRead
                wrap.event.onAfterWrite = Socket.onAfterWrite
                wrap.event.onClose = Socket.onClose
            }
        }
        
        Tcp.bind(self.server.tcpHandle, address : self.ip, port: self.port)
        Tcp.listen(self.server.tcpHandle)
    
    }
    
}
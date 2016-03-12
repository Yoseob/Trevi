//
//  Net.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 20..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


/**
Socket interface for Net or Net users.
Should be inherited StreamReadable.
*/
public class Socket: EventEmitter {
    
    public let timer : Timer = Timer()
    
    public static var dictionary = [uv_stream_ptr : Socket]()
    
    public var handle: uv_stream_ptr!
    public var ondata: (( NSData, Int )->Void)?
    public var onend: ((Void)->(Void))?
    
    public init(handle: uv_stream_ptr) {
        
        self.handle = handle
        super.init()
        
        // Set dictionary to get the object by stream pointer
        Socket.dictionary[handle] = self
    }
    
    
    public func write(data: NSData, handle : uv_stream_ptr) {
 
        Stream.doWrite(data, handle: handle)
    }
    
    // Shutdown handle first to block close the Socket while writting.
    // After that, close Socket and onClose will be called.
    public func close() {
    
        Stream.doShutDown(handle)
    }
    
    
    // Block to close the Socket in delay msecs.
    public func setKeepAlive(msecs: UInt32) {
        
        Tcp.setKeepAlive(uv_tcp_ptr(self.handle), enable: 1, delay: msecs)
    }
    
}


// Socket static callbacks. These support closure event.
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
    

    // Set timeout to close the Socket after msecs from last write call.
    public static func onAfterWrite(handle: uv_stream_ptr) -> Void {
        
        if let wrap = Socket.dictionary[uv_stream_ptr(handle)] {
            Socket.onTimeout(wrap.timer.timerhandle, msecs: 40) {
                _ in
                
                Stream.doShutDown(handle)
            }
        }
    }

    public static func onClose(handle : uv_handle_ptr) {
        
        if let wrap = Socket.dictionary[uv_stream_ptr(handle)] {
            wrap.onend!()
            wrap.events.removeAll()
            wrap.ondata = nil
            wrap.onend = nil
            wrap.timer.close()
            Socket.dictionary.removeValueForKey(uv_stream_ptr(handle))
        }
    }
    
    
    // Set timer event. This will remove previous event and start new event on Socket.
    public static func onTimeout( handle : uv_timer_ptr, msecs : UInt64, callback : ((uv_timer_ptr)->()) ) {
        
        if let wrap = Handle.dictionary[uv_handle_ptr(handle)]{
            wrap.event.onTimeout = callback
            Timer.stop(handle)
            Timer.start(handle, timeout: msecs, count: 0)
        }
    }
        
}


/**
Network module with system and Trevi. 
 
 Target : 
 
 public class EchoServer : Net {
 
     public init(){
         super.init()
         self.on("connection", connectionListener)
     }
 
     func connectionListener(sock: AnyObject){
 
         let socket = sock as! Socket
 
         // Set event when get a data.
         socket.ondata = { data, nread in
             socket.write(data, handle: socket.handle)
         }
 
         // Set end event.
         socket.onend = { }
    }
 }
 */
public class Net: EventEmitter {
    
    public let ip : String
    public var port : Int32
    
    public let server : Tcp
    
    public init(ip : String = "0.0.0.0") {
        self.ip = ip
        self.port = 8080
        self.server = Tcp()
    }
    
   
    public func listen(port: Int32) -> Int32? {
        self.port = port
        
        // Set listening event to call user function when start server.
        self.emit("listening")
        
        self.server.event.onConnection = { 
            client in
            
            // Set user callback events.
            Socket.onConnection(client, self)
            
            if let wrap = Handle.dictionary[uv_handle_ptr(client)] {
                
                wrap.event.onRead = Socket.onRead
                wrap.event.onAfterWrite = Socket.onAfterWrite
                wrap.event.onClose = Socket.onClose
            }
        }
        
        guard let _ = Tcp.bind(self.server.tcpHandle, address : self.ip, port: self.port) else {
            return nil
        }
        guard let _ = Tcp.listen(self.server.tcpHandle) else {
            return nil
        }
        
        return 0
    }
    
}
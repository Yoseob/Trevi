//
//  Work.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 25..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public class Work {
    
    public let workRequest : uv_work_ptr
    
    init(){
        self.workRequest = uv_work_ptr.alloc(1)
    }
    
    deinit{
        self.workRequest.dealloc(1)
    }
    
    public func setWorkData(dataPtr : void_ptr) {
        self.workRequest.memory.data = dataPtr
    }
}


// Work static functions.

extension Work {
    
    struct connectionInfo {
        var handle : uv_stream_ptr
        var status : Int32
    }
    
    public static var onConnection : uv_connection_cb = { (handle, status) in
        
        let work : Work = Work()
        let info = UnsafeMutablePointer<connectionInfo>.alloc(1)
        
        info.memory.handle = handle
        info.memory.status = status
        
        work.workRequest.memory.data = void_ptr(info)
        
        uv_queue_work( uv_default_loop(), work.workRequest, workConnection, afterWork )
    }
    
    struct readInfo {
        var handle : uv_stream_ptr
        var nread : Int
        var buffer : uv_buf_const_ptr
    }
    
    public static var onRead : uv_read_cb = { (handle, nread, buffer) in
        
        let work : Work = Work()
        let info = UnsafeMutablePointer<readInfo>.alloc(1)
        
        info.memory.handle = handle
        info.memory.nread = nread
        info.memory.buffer = buffer
        
        uv_queue_work( uv_default_loop(), work.workRequest, workRead, afterWork )
    }
}


// Work static callbacks.

extension Work {
    
    public static var workConnection : uv_work_cb = { (handle) in
        let info = UnsafeMutablePointer<connectionInfo>(handle.memory.data)
        
        Tcp.onConnection(info.memory.handle, info.memory.status)
        info.dealloc(1)
    }
    
    public static var workRead : uv_work_cb = { (handle) in
        let info  = UnsafeMutablePointer<readInfo>(handle.memory.data)
        
        Tcp.onRead(info.memory.handle, info.memory.nread, info.memory.buffer)
        info.dealloc(1)
    }
    
    public static var afterWork : uv_after_work_cb = { (handle, status) in
        
        handle.dealloc(1)
    }
}


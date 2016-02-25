//
//  Work.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 25..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

public class Work {

    let workRequest : uv_work_ptr
    
    init(){
        self.workRequest = uv_work_ptr.alloc(1)
    }
    
    deinit{
        
    }
    
    public func setWorkData(dataPtr : void_ptr) {
        self.workRequest.memory.data = dataPtr
    }
}


// Work static functions.

extension Work {
    
    struct connectionInfo {
        let handle : uv_stream_ptr
        let status : Int32
    }
    
    public static var onConnection : uv_connection_cb = { (handle, status) in
        
        let work : Work = Work()
        var info : connectionInfo = connectionInfo(handle: handle, status: status)
        
        work.setWorkData( withUnsafeMutablePointer(&info){ void_ptr($0) } )
        
        uv_queue_work( uv_default_loop(), work.workRequest, workConnection, Work.afterWork )
    }
    
    struct readInfo {
        let handle : uv_stream_ptr
        let nread : Int
        let buffer : uv_buf_const_ptr
    }
    
    public static var onRead : uv_read_cb = { (handle, nread, buffer) in
        
        let work : Work = Work()
        var info : readInfo = readInfo(handle: handle, nread : nread, buffer : buffer)
        
        work.setWorkData( withUnsafeMutablePointer(&info){ void_ptr($0) } )
        
        uv_queue_work( uv_default_loop(), work.workRequest, workRead, Work.afterWork )
    }
}


// Work static callbacks.

extension Work {
    
    public static var workConnection : uv_work_cb = { (handle) in
        let info : connectionInfo = UnsafeMutablePointer<connectionInfo>(handle.memory.data).memory
        
        Tcp.onConnection(info.handle, info.status)
    }
    
    public static var workRead : uv_work_cb = { (handle) in
        let info : readInfo = UnsafeMutablePointer<readInfo>(handle.memory.data).memory

        Tcp.onRead(info.handle, info.nread, info.buffer)
    }
    
    public static var afterWork : uv_after_work_cb = { (handle, status) in
        uv_cancel(uv_req_ptr(handle))
        handle.dealloc(1)
    }
}


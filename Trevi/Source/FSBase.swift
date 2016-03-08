//
//  FSBase.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 27..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


public class FSBase {
    
    public static let BUF_SIZE = 1024
    public static var dictionary = [uv_fs_ptr : FSBase]()
    
    public typealias fsCallback = (uv_fs_ptr)->Void
    public var events = [uv_fs_type : fsCallback]()
    
    public let fsRequest : uv_fs_ptr
    
    public init() {
        
        self.fsRequest = uv_fs_ptr.alloc(1)
        
        let buffer = uv_buf_ptr.alloc(1)
        self.setWorkData(void_ptr(buffer))
        
        FSBase.dictionary[self.fsRequest] = self
    }
    
    deinit {
        self.fsRequest.dealloc(1)
        self.events.removeAll()
    }
    
    public func setWorkData(dataPtr : void_ptr) {
        self.fsRequest.memory.data = dataPtr
    }
    
}

public struct FSInfo {
    public var request : uv_fs_ptr
    public var loop : uv_loop_ptr
    public var toRead : UInt64
}


// FsBase static functions

extension FSBase {

    
    public static func open(loop : uv_loop_ptr, handle : uv_pipe_ptr! = nil, path : String, flags : Int32, mode : Int32) -> Int32 {
        
        let request = uv_fs_ptr.alloc(1)
        
        let fd = uv_fs_open(loop, request, path, flags, mode, nil)
        uv_fs_stat(loop, request, path, nil)
        
        let info =  UnsafeMutablePointer<FSInfo>.alloc(1)
        info.memory.request = request
        info.memory.loop = loop
        info.memory.toRead = request.memory.statbuf.st_size
        
        if let handle = handle {
            handle.memory.data = void_ptr(info)
        }
        
        return fd
    }
    
    public static func close(loop : uv_loop_ptr, request : uv_fs_ptr) {
        
        let closeRequest = uv_fs_ptr.alloc(1)
        uv_fs_close(loop, closeRequest, uv_file(request.memory.result), onClose)
    }
    
    public static func read(request : uv_fs_ptr) {
        
        let buffer =  uv_buf_ptr(request.memory.data)
        buffer.memory = uv_buf_init(UnsafeMutablePointer<Int8>.alloc(BUF_SIZE), UInt32(BUF_SIZE))
        
        uv_fs_read(uv_default_loop(), request, uv_file(request.memory.result), buffer, 1, -1, onRead)
    }
    
    public static func write(buffer: uv_buf_const_ptr, fd : uv_file) {
        
        let request : uv_fs_ptr = uv_fs_ptr.alloc(1)
        
        request.memory.data = void_ptr(buffer)
        
        uv_fs_write(uv_default_loop(), request, fd, buffer, 1, -1, afterWrite)
    }
    
    public static func cleanup(request : uv_fs_ptr) {
        
        FSBase.dictionary[request] = nil
        uv_fs_req_cleanup(request)
    }
    
}

// FsBase static callbacks

extension FSBase {
    
    public static var after : ((uv_fs_ptr, uv_fs_type)->()) = { (request, type) in
        
        if let wrap = FSBase.dictionary[request]{
            if let callback = wrap.events[type] {
                callback(request)
            }
        }
    }
    
    public static var onOpen : uv_fs_cb  = { request in
        
        if request.memory.result >= 0 {
            
            after(request, UV_FS_OPEN)
        }
        else {
            print("Filesystem open error : \(uv_strerror(Int32(request.memory.result)))")
        }
        
    }
    
    public static var onClose : uv_fs_cb  = { request in
        
        after(request, UV_FS_CLOSE)
        
        FSBase.cleanup(request)
        uv_cancel(uv_req_ptr(request))
        request.dealloc(1)
    }
    
    public static var onRead : uv_fs_cb  = { request in
        
        if request.memory.result < 0 {
            
            print("Filesystem read error : \(uv_strerror(Int32(request.memory.result)))")
        }
        else if request.memory.result == 0 {

            FSBase.close(uv_default_loop(), request: request)
        }
        else {
            
            after(request, UV_FS_READ)
        }
    }
    
    public static var afterWrite : uv_fs_cb  = { request in
        
        after(request, UV_FS_WRITE)
        
        let buffer : uv_buf_const_ptr = uv_buf_const_ptr(request.memory.data)
        
        if buffer.memory.len > 0 {
            buffer.memory.base.dealloc(buffer.memory.len)
        }
        
        uv_cancel(uv_req_ptr(request))
        request.memory.data.dealloc(1)
        request.dealloc(1)
    }
}

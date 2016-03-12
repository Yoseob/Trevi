//
//  FsBase.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 27..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation

/**
 Libuv Filesystem bindings and events module, but considering better way.
 So, hope to use FileSystem on Trevi temporary.
 */
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
    
    
    public static func open(loop : uv_loop_ptr = uv_default_loop(), handle : uv_pipe_ptr! = nil, path : String, flags : Int32, mode : Int32) -> Int32 {
        
        let fd = UnsafeMutablePointer<uv_file>.alloc(1)
        let request = uv_fs_ptr.alloc(1)
        
        fd.memory = uv_fs_open(loop, request, path, flags, mode, nil)
        uv_fs_stat(loop, request, path, nil)
        
        request.memory.data = void_ptr(fd)
        
        let info =  UnsafeMutablePointer<FSInfo>.alloc(1)
        
        info.memory.request = request
        info.memory.loop = loop
        info.memory.toRead = request.memory.statbuf.st_size
        
        if let handle = handle {
            handle.memory.data = void_ptr(info)
        }
        
        return fd.memory
    }
    
    public static func close(loop : uv_loop_ptr = uv_default_loop(), request : uv_fs_ptr) {
        
        let fd = UnsafeMutablePointer<uv_file>(request.memory.data)
        let closeRequest = uv_fs_ptr.alloc(1)
        
        uv_fs_close(loop, closeRequest, fd.memory, onClose)
        
        fd.dealloc(1)
        FSBase.cleanup(request)
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
    
    public static func unlink(loop : uv_loop_ptr = uv_default_loop(), request : uv_fs_ptr, path : String) {
        let error = uv_fs_unlink(loop, request, path, FSBase.afterUnlink)
        
        if error == 0 {
            // Should handle error
            
        }
    }
    
    public static func makeDirectory(loop : uv_loop_ptr = uv_default_loop(), request : uv_fs_ptr, path : String, mode : Int32 = 0o666) {
        let error = uv_fs_mkdir(loop, request, path, mode, FSBase.afterMakeDirectory)
        
        if error == 0 {
            // Should handle error
            
        }
    }
    
    public static func cleanup(request : uv_fs_ptr) {
        
        //        FSBase.dictionary[request] = nil
        uv_fs_req_cleanup(request)
        request.dealloc(1)
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
        
//        after(request, UV_FS_CLOSE)
        
        FSBase.cleanup(request)
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
    
    public static var afterUnlink : uv_fs_cb = { request in
        
    }
    
    public static var afterMakeDirectory : uv_fs_cb = { request in
        
    }
}

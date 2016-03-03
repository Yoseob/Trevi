//
//  FsBase.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 27..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


public class FsBase {
    
    public static let BUF_SIZE = 1024
    public static var dictionary = [uv_fs_ptr : FsBase]()
    
    public typealias fsCallback = (uv_fs_ptr)->Void
    public var events = [uv_fs_type : fsCallback]()
    
    public let fsRequest : uv_fs_ptr
    
    public init() {
        
        self.fsRequest = uv_fs_ptr.alloc(1)
        
        let buffer = uv_buf_ptr.alloc(1)
        self.setWorkData(void_ptr(buffer))
        
        FsBase.dictionary[self.fsRequest] = self
        
        print("FS init")
    }
    
    deinit {
        self.fsRequest.dealloc(1)
        self.events.removeAll()
        
        print("FS deinit")
    }
    
    public func setWorkData(dataPtr : void_ptr) {
        self.fsRequest.memory.data = dataPtr
    }
    
}


// FsBase static functions

extension FsBase {
    
    public static func open(request : uv_fs_ptr, path : String, flags : Int32) -> Int32 {
        
       return uv_fs_open(uv_default_loop(), request, path, flags, 0644, onOpen)
    }
    
    public static func close(request : uv_fs_ptr) {
        
        let closeRequest = uv_fs_ptr.alloc(1)
        uv_fs_close(uv_default_loop(), closeRequest, uv_file(request.memory.result), onClose)
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
        
        FsBase.dictionary[request] = nil
        uv_fs_req_cleanup(request)
    }
    
}


// FsBase static internal module.

extension FsBase {
    
    public struct Info {
        let request : uv_fs_ptr
        let size : UInt64
        var nread : Int
    }
    
    public static func streamReadFile(handle : uv_pipe_ptr, path : String) {
        
        let request = uv_fs_ptr.alloc(1)
        let fd = uv_fs_open(uv_default_loop(), request, path, O_RDONLY, 0, nil)
        
        Pipe.open(handle, fd: fd)
        uv_fs_stat(uv_default_loop(), request, path, nil)
        
        let stat = request.memory.statbuf
        var info = Info(request: request, size: stat.st_size, nread: 0)
        
        handle.memory.data = withUnsafeMutablePointer(&info){ void_ptr($0) }
        
        Stream.readStart(uv_stream_ptr(handle))
        
        Loop.run(mode: UV_RUN_ONCE)
    }
    
    
    // Should add close callback after write in Stream module.
    
    public static func streamOpenFile(handle : uv_pipe_ptr, path : String) {
        
        let request = uv_fs_ptr.alloc(1)
        let fd = uv_fs_open(uv_default_loop(), request, path, O_CREAT | O_RDWR, 6644, nil)
        
        Pipe.open(handle, fd: fd)
    }
    
    
    // Should add close callback after write in Stream module.
    
    public static func streamWriteFile(handle : uv_pipe_ptr, data : NSData) {
        
        Stream.doWrite(data, handle: uv_stream_ptr(handle))
        Loop.run(mode: UV_RUN_ONCE)
    }
    
}

// FsBase static callbacks

extension FsBase {
    
    public static var after : ((uv_fs_ptr, uv_fs_type)->()) = { (request, type) in
        
        if let wrap = FsBase.dictionary[request]{
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
        
        FsBase.cleanup(request)
        uv_cancel(uv_req_ptr(request))
        request.dealloc(1)
    }
    
    public static var onRead : uv_fs_cb  = { request in
        
        if request.memory.result < 0 {
            
            print("Filesystem read error : \(uv_strerror(Int32(request.memory.result)))")
        }
        else if request.memory.result == 0 {

            FsBase.close(request)
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

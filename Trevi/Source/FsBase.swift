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
        
        print("FS deinit")
    }
    
    public func setWorkData(dataPtr : void_ptr) {
        self.fsRequest.memory.data = dataPtr
    }
    
}


// Filesystem static functions

extension FsBase {
    
    public static func open(request : uv_fs_ptr, path : String) {
        
        uv_fs_open(uv_default_loop(), request, path, O_RDONLY, 0, onOpen)
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
    
    public static func write(request : uv_fs_ptr, path : String) {
        
        //        uv_fs_write(uv_default_loop(), request, request.memory.result, 0, onWrite)
    }
    
    public static func cleanup(request : uv_fs_ptr) {
        
        let buffer =  uv_buf_ptr(request.memory.data)
        
        if buffer.memory.len > 0 {
            buffer.memory.base.dealloc(buffer.memory.len)
        }
        buffer.dealloc(1)
        
        FsBase.dictionary[request] = nil
        uv_fs_req_cleanup(request)
    }
    
}


// Filesystem static callbacks

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
        request.dealloc(1)
    }
    
    
    public static var onRead : uv_fs_cb  = { request in
        
        if request.memory.result < 0 {
            
            print("Filesystem read error : \(uv_strerror(Int32(request.memory.result)))")
        }
        else if request.memory.result == 0 {
            
            print("close called")
            FsBase.close(request)
        }
        else {
            
            after(request, UV_FS_READ)
        }
        
    }
    
    
    public static var onWrite : uv_fs_cb  = { request in
        
        
        after(request, UV_FS_WRITE)
    }
}

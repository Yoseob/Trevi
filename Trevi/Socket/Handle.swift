//
//  Handle.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

public class Handle {
    public let handle : uv_handle_ptr
    
    public init (handle : uv_handle_ptr) {
        self.handle = handle
    }
    deinit {
        
    }
}


// Handle static properties and methods

extension Handle {
    
    public static func ref(handle : uv_handle_ptr) {
        uv_ref(handle)
    }
    
    public static func unref(handle : uv_handle_ptr){
        uv_unref(handle)
    }
    
    public static func getFD(handle : uv_handle_ptr) -> Int32 {
        var fd : uv_os_fd_t = uv_os_fd_t.init(littleEndian: -1)
        uv_fileno(handle, &fd)
        
        return fd
    }
    
    public static func isAlive(handle : uv_handle_ptr!) -> Bool {
       // handle.memory is never nil
        return true
    }
    
    public static func close(handle : uv_handle_ptr) {
        uv_close(handle, Handle.onClose)
        handle.destroy()
    }
    
    public static func isClosing(handle : uv_handle_ptr) -> Bool {
        return uv_is_closing(handle) != 0
    }
    
    
    public static var onClose : uv_close_cb = { handle in
        // State after close callback
        
    }
}
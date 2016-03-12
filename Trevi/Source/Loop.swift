//
//  Loop.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 21..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


/**
 Libuv Loop bindings.
 */
public class Loop {
    
    public let loopHandle : uv_loop_ptr
    
    public init() {
        
        self.loopHandle = uv_loop_ptr.alloc(1)
        uv_loop_init(self.loopHandle)
    }
    
    deinit {
        self.loopHandle.dealloc(1)
    }
    
}


// Loop static functions.

extension Loop {
    
    // Closes all internal loop resources and the loop will be terminated
    public static func close(handle : uv_loop_ptr) {
        
        uv_loop_close(handle)
        
//        Should handle a signal error on FileSystem writeStream.
//        Handle.close(uv_handle_ptr(handle))
    }
    
    
    public static func run(handle : uv_loop_ptr = uv_default_loop(), mode : uv_run_mode) {
        
        let error = uv_run(handle, mode)
        
        if error != 0 {
            // Should handle error
        }
    }
    
    
    public static func active(handle : uv_loop_ptr) {
        let error = uv_loop_alive(handle)
        
        if error != 0 {
            // Should handle error
        }
    }
    
    
    public static func getFD(handle : uv_loop_ptr)->Int32 {
        return uv_backend_fd(handle)
    }
    
    
    public static func walk(handle : uv_loop_ptr) {
        
        uv_walk(handle, Loop.onWalk, uv_handle_ptr(handle).memory.data)
    }
}


// Loop static callbacks.

extension Loop {
    
    public static var onWalk : uv_walk_cb = { (handle, argument) in
        
    }
}
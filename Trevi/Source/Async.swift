//
//  Async.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 11..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


/**
 Libuv Async bindings.
 */
public class Async : Handle {
    
    public let asyncHandle : uv_async_ptr
    
    public init () {
        
        self.asyncHandle = uv_async_ptr.alloc(1)
        uv_async_init(uv_default_loop(), self.asyncHandle, Async.callback)
        
        super.init(handle: uv_handle_ptr(self.asyncHandle))
    }
    
    deinit {
        if isAlive {
            Handle.close(self.handle)
            self.asyncHandle.dealloc(1)
            isAlive = false
        }
    }
}


// Async static functions.

extension Async {
    
    public static func send(handle : uv_async_ptr) {
        
        uv_async_send(handle)
    }
}


// Async static callbacks.

extension Async {
    
    public static var callback : uv_async_cb = { (handle) in
        
    }
}
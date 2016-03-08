//
//  Timer.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 21..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

public class Timer : Handle {
    
    public let timerhandle : uv_timer_ptr
    
    public init() {
        
        self.timerhandle = uv_timer_ptr.alloc(1)
        uv_timer_init(uv_default_loop(), self.timerhandle)
        
        super.init(handle: uv_handle_ptr(self.timerhandle))
        
    }
    
    public func close() {
        Handle.close(self.handle)
    }
    
}


// Timer static functions.

extension Timer {
    
    public static func start(handle : uv_timer_ptr, timeout : UInt64,  count : UInt64 = 1) {
        uv_timer_start(handle, Timer.onTimeout , timeout, count)
    }
    
    public static func stop(handle : uv_timer_ptr) {
        uv_timer_stop(handle)
    }
    
    public static func again(handle : uv_timer_ptr) {
        uv_timer_again(handle)
    }
    
    public static func setRepeat(handle : uv_timer_ptr, count : UInt64) {
        uv_timer_set_repeat(handle, count)
    }
}


// Timer static callbacks.

extension Timer {
    
    public static var onTimeout : uv_timer_cb = { (handle) in
        
        if let wrap = Handle.dictionary[uv_handle_ptr(handle)] {
            if let callback =  wrap.event.onTimeout {
                callback(handle)
            }
        }
    }
}
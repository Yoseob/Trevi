//
//  Poll.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 13..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


/**
Libuv Poll bindings.
*/

public class Poll : Handle {
    
    let pollHandle : uv_poll_ptr
    
    public init(loop : uv_loop_ptr = uv_default_loop(), fd : Int32, isSocket : Bool) {
        
        self.pollHandle = uv_poll_ptr.alloc(1)
        
        if isSocket {
            uv_poll_init_socket(loop, self.pollHandle, fd)
        }
        else {
            uv_poll_init(loop, self.pollHandle, fd)
        }
        
        super.init(handle: uv_handle_ptr(self.pollHandle))
    }
    
    deinit {
        if isAlive {
            Handle.close(self.handle)
            self.pollHandle.dealloc(1)
            isAlive = false
        }
    }
}



// Poll static functions.

extension Poll {
    
    // event should be one of UV_READABLE and UV_WRITABLE.
    public static func start(handle : uv_poll_ptr, event : uv_poll_event) {
        
        let error = uv_poll_start(handle, Int32(event.rawValue), Poll.onStart)
        
        // Should handle error
        if error == 0 {
            
        }
    }
}


// Poll static callbacks.

extension Poll {
    
    public static var onStart : uv_poll_cb = { (handle, first, second) in
        
        if let wrap = Handle.dictionary[uv_handle_ptr(handle)] {
            // Should add Poll start callback event
            
        }
    }
}
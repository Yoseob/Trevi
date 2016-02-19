//
//  Handle.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv

public class Handle {
    
    static var dictionary = [uv_handle_ptr : Handle]()
    
    public let event : Event
    public let handle : uv_handle_ptr
    
    public init (handle : uv_handle_ptr) {
        self.handle = handle
        self.event = Event()
        Handle.dictionary[self.handle] = self
    }
    deinit {
        print("Handle deinit")
        Handle.close(self.handle)
    }
}


// Handle static functions.

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
    
    public static func isActive(handle : uv_handle_ptr) -> Bool {
       // handle.memory is never nil
        
        return uv_is_active(handle) != 0
    }
    
    public static func close(handle : uv_handle_ptr) {
        
        if !Handle.isClosing(handle){
            
            uv_close(handle, Handle.onClose)
        }
    }
    
    public static func isClosing(handle : uv_handle_ptr) -> Bool {
        return uv_is_closing(handle) != 0
    }
    
}


// Handle static functions.

extension Handle {
    
    public static var onClose : uv_close_cb = { handle in
        // State after close callback
        
        if let wrap = Handle.dictionary[handle] {
            if let callback =  wrap.event.onClose {
                callback(handle)
            }
        }
        
        Handle.dictionary[handle] = nil
    }
}
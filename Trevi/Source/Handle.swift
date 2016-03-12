//
//  Handle.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv
import Foundation

/**
    Top class in Libuv handle classes. All handle classes are supposed to be inherited this.
    Manages all handle events, object, memory.
    Libuv handle api reference : http://docs.libuv.org/en/v1.x/index.html
 */
public class Handle {
    
    public static var dictionary = [uv_handle_ptr : Handle]()
    
    public var event : Event
    public let handle : uv_handle_ptr
    
    public var isAlive : Bool
    
    public init (handle : uv_handle_ptr) {
    
        self.isAlive = true
        self.handle = handle
        self.event = Event()
        
        // Set dictionary to get the object by uv handle pointer
        Handle.dictionary[self.handle] = self
    }
    
    deinit {
        if isAlive {
            Handle.close(self.handle)
            self.handle.dealloc(1)
            isAlive = false
        }
    }
    
}


// Handle event inner class

extension Handle {
    
    public class Event {
        
        // Can be set or used after get object with any uv handles from dictionary
        
        public var onClose : ((uv_handle_ptr)->())!
        public var onAlloc : Any!
        public var onRead : ((uv_stream_ptr, NSData)->())!
        public var afterShutdown : Any!
        public var onAfterWrite : ((uv_stream_ptr)->())!
        public var onConnection : (uv_stream_ptr -> ())!
        public var afterConnect : Any!
        public var onTimeout : ((uv_timer_ptr)->())!
        
    }
}


// Handle static functions.

extension Handle {
    
    public static func ref(handle : uv_handle_ptr) {
        uv_ref(handle)
    }
    
    public static func unref(handle : uv_handle_ptr) {
        uv_unref(handle)
    }
    
    public static func getFD(handle : uv_handle_ptr) -> Int32 {
        var fd : uv_os_fd_t = uv_os_fd_t.init(littleEndian: -1)
        uv_fileno(handle, &fd)
        
        return fd
    }
    
    public static func isActive(handle : uv_handle_ptr) -> Bool {
        
        return uv_is_active(handle) != 0
    }
    
    
    // Must be called before handle pointer memory is released.
    // Free up any resources associated with the handle on Handle.onClose callback.
    public static func close(handle : uv_handle_ptr) {
        if !Handle.isClosing(handle){
            
            uv_close(handle, Handle.onClose)
        }
    }
    
    public static func isClosing(handle : uv_handle_ptr) -> Bool {
        return uv_is_closing(handle) != 0
    }
    
}


// Handle static callbacks.

extension Handle {
    
    // After this callback this Handle object will be deinit
    public static var onClose : uv_close_cb = { handle in
        
        if let wrap = Handle.dictionary[handle] {
            if let callback =  wrap.event.onClose {
                callback(handle)
            }
        }
        
        Handle.dictionary[handle] = nil
    }
}
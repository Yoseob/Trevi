//
//  Pipe.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 29..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


public class Pipe : Stream {
    
    public let pipeHandle : uv_pipe_ptr
    
    public init(loop : uv_loop_ptr = uv_default_loop(), ipc : Int32 = 0){
        self.pipeHandle = uv_pipe_ptr.alloc(1)
        
       uv_pipe_init(loop, self.pipeHandle, ipc)
        
        super.init(streamHandle: uv_stream_ptr(self.pipeHandle))
        
    }
    deinit{
    }

}


// Pipe static functions

extension Pipe {
    
    public static func open(handle : uv_pipe_ptr, fd : uv_file) {
        
        let error = uv_pipe_open(handle, fd)
        
        if error != 0 {
            // Should handle error
        }
    }
    
    public static func bind(handle : uv_pipe_ptr, path : String) {
        
        let error = uv_pipe_bind(handle, path)
        
        if error != 0 {
            // Should handle error
        }
    }
    
    public static func connect(handle : uv_pipe_ptr, path : String) {
        
        let request : uv_connect_ptr = uv_connect_ptr.alloc(1)
        
        uv_pipe_connect(request, handle, path, Pipe.afterConnect)
    }
    
    public static func listen(handle : uv_pipe_ptr, backlog : Int32 = 50) {
        
        let error = uv_listen(uv_stream_ptr(handle), backlog, Pipe.onConnection)
        
        if error != 0 {
            // Should handle error
        }
    }
}


// Pipe static callbacks

extension Pipe {
    
    public static var afterConnect : uv_connect_cb = { (request, status) in
        
        request.dealloc(1)
    }
    
    public static var onConnection : uv_connection_cb = { (handle, status) in
        
        var client = Pipe()
        
        if uv_accept(handle, client.streamHandle) != 0 {
            return
        }
        
        // Should add client callbacks
    }
    
}


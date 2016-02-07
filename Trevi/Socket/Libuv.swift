//
//  Libuv.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 4..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

public typealias uv_loop_ptr = UnsafeMutablePointer<uv_loop_t>
public typealias uv_poll_ptr = UnsafeMutablePointer<uv_poll_t>

// Libuv Test class
public class Libuv {
    
    var uvloop : uv_loop_ptr
    
    public init() {
        
        self.uvloop = uv_default_loop()
        uv_loop_init(self.uvloop)
    }
    
    deinit {
        uv_loop_close(self.uvloop)
    }
}

public class LibuvPoll {
    
    let fd : Int32
    var loop : uv_loop_ptr
    var handle : uv_poll_t
    
    public init(fd : Int32, loop : uv_loop_ptr, domain : Int32) {
        self.fd = fd
        self.loop = loop
        self.handle = uv_poll_t()
        
        uv_poll_init(self.loop, &self.handle, self.fd)
        uv_poll_init_socket(self.loop, &self.handle, domain)
        
    }
    
    deinit {
        uv_poll_stop(&self.handle)
    }
    
    // Testing readable / writable event
    // uv_poll_cb  =  @convention(c) (UnsafeMutablePointer<uv_poll_s>, Int32, Int32) -> ()
    public func readableTest(){
        uv_poll_start(&self.handle, Int32(UV_READABLE.rawValue)){
            _, first, second in
            Darwin.accept(6, UnsafeMutablePointer<sockaddr>(), UnsafeMutablePointer<socklen_t>())
            print("readable \(first), \(second)")
        }
    }
    
    public func writableTest(){
        uv_poll_start(&self.handle, Int32(UV_WRITABLE.rawValue)) {
            _ in
            print("writable!")
        }
    }
}

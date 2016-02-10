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

public class Libuv {
    
    let fd : Int32
    var loop : uv_loop_ptr
    var handle : uv_poll_ptr
    
    // uv_poll_cb  =  @convention(c) (UnsafeMutablePointer<uv_poll_s>, Int32, Int32) -> ()
    var readCallback : uv_poll_cb! = nil
    var writeCallback : uv_poll_cb! = nil
    
    public init(fd : Int32, loop : uv_loop_ptr = uv_default_loop()) {
        self.fd = fd
        self.loop = loop
        self.handle = uv_poll_ptr.alloc(1)
        
        uv_loop_init(self.loop)
        uv_poll_init(self.loop, self.handle, self.fd)
        uv_poll_init_socket(self.loop, self.handle, self.fd)
    }
    
    deinit {
        uv_loop_close(self.loop)
        uv_poll_stop(self.handle)
    }
    
    // Testing readable / writable event
    public func readableTest() -> Bool {
        
        self.readCallback = {
            pollPtr, first, second in
            
            var pfd : uv_os_fd_t = uv_os_fd_t()
            uv_fileno(UnsafeMutablePointer<uv_handle_t>(pollPtr), &pfd)
            
            var caddr = IPv4()
            var caddrLen = socklen_t(IPv4.length)
            
            let cfd = withUnsafeMutablePointer(&caddr) {
                ptr -> Int32 in
                let addrPtr = UnsafeMutablePointer<sockaddr>(ptr)
                
                #if os(Linux)
                    return SwiftGlibc.accept(pfd, addrPtr, &caddrLen)
                #else
                    return Darwin.accept(pfd, addrPtr, &caddrLen)
                #endif
            }
            
            let cSocket = ConnectedSocket<IPv4>(fd: cfd, address: caddr)
            print(cSocket!.nonblock)
            print("New client fd : \(cfd), address : \(cSocket!.address.ip())")
        }
        
        if let callback = self.readCallback {
            uv_poll_start(self.handle, Int32(UV_READABLE.rawValue), callback)
            self.runLoop()
            return true
        }
        log.error("Libuv read callback is not set. Please set the read callback before execute this function.")
        return false
    }
    
    public func writableTest(){
        uv_poll_start(self.handle, Int32(UV_WRITABLE.rawValue)) {
            _ in
            print("writable!")
        }
    }
    
    public func runLoop(){
        //uv_loop_configure(self.loop, UV_LOOP_BLOCK_SIGNAL)
        uv_run(self.loop, UV_RUN_DEFAULT)
    }
    
    
    // test error log, should be modified.
    public func printError(){
        print(blockToUTF8String(uv_strerror(UV_EAGAIN.rawValue)))
    }
}

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

public typealias uv_callback = @convention(c) (UnsafeMutablePointer<uv_poll_s>, Int32, Int32) -> ()


//public struct curl_context_s {
//    let poll_handle : uv_poll_t
//    let sockfd : Int32
//}

public class Libuv {
    
    let fd : Int32
    var loop : uv_loop_ptr
    var handle : uv_poll_ptr

//    lazy var swiftCallback : @convention(c) (UnsafeMutablePointer<uv_poll_s>, Int32, Int32) -> Void = {
//         ptr, first, second in
//        Darwin.accept(6, UnsafeMutablePointer<sockaddr>(), UnsafeMutablePointer<socklen_t>())
//        print("readable \(first), \(second)")
//    }
    
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
    // uv_poll_cb  =  @convention(c) (UnsafeMutablePointer<uv_poll_s>, Int32, Int32) -> ()
    public func readableTest(){
        
        uv_poll_start(self.handle, Int32(UV_READABLE.rawValue)) {
            ptr, first, second in
//            var mutex = pthread_mutex_t()
//            pthread_mutex_init(&mutex, nil)
//            pthread_mutex_lock(&mutex)
            
            var tfd : uv_os_fd_t = uv_os_fd_t()
            uv_fileno(UnsafeMutablePointer<uv_handle_t>(ptr), &tfd)
            print(tfd)
            
            Darwin.accept(tfd, UnsafeMutablePointer<sockaddr>(), UnsafeMutablePointer<socklen_t>())
            print("readable \(first), \(second)")
            
//            pthread_mutex_unlock(&mutex)
        }
        self.runLoop()
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

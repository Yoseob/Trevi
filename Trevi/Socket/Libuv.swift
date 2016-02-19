//
//  Libuv.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 4..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv


// Libuv test file

// Stream
public struct write_req_t {
    let req: uv_write_t
    var buf: uv_buf_t
}

public func alloc_buffer(handle: UnsafeMutablePointer<uv_handle_t>, _ suggested_size: Int, _ buf: UnsafeMutablePointer<uv_buf_t>) -> Void {
    buf.initialize(uv_buf_init(UnsafeMutablePointer<Int8>.alloc(suggested_size), UInt32(suggested_size)))
}

public func write_data(dest: UnsafeMutablePointer<uv_stream_t>, _ size: Int, _ buf: uv_buf_t, _ cb: uv_write_cb) -> Void {
    
    let req = UnsafeMutablePointer<write_req_t>.alloc(1)
    
    req.memory.buf = uv_buf_init(UnsafeMutablePointer<Int8>.alloc(size), UInt32(size))
    memcpy(req.memory.buf.base, buf.base, size)
    uv_write(UnsafeMutablePointer<uv_write_t>(req), dest, &req.memory.buf, 1, cb)
}

public func free_write_req(req: UnsafeMutablePointer<uv_write_t>) {
    let write_req = UnsafeMutablePointer<write_req_t>(req)
    write_req.memory.buf.base.dealloc(write_req.memory.buf.len)
    write_req.dealloc(1)
}

public func on_write(req: UnsafeMutablePointer<uv_write_t>, status: Int32) -> Void {
    print("========on_write=========")
    free_write_req(req)
}

public func echo_read(stream: UnsafeMutablePointer<uv_stream_t>, _ nread: Int, _ buf: UnsafePointer<uv_buf_t>) -> Void {
    print("echo_read: start, nread: \(nread)")
    
    if nread < 0 {
        if Int32(nread) == UV_EOF.rawValue {
            print(buf.memory.len)
            print("")
            print("======= echo_read: end of file, closing ======")
            print("")
            
            Handle.dictionary[uv_handle_ptr(stream)] = nil
        }
    }
    else if (nread > 0) {
        print(blockToString(buf.memory.base, length: nread))
        write_data(UnsafeMutablePointer<uv_stream_t>(stream), nread, buf.memory, on_write)
    }
    
    if buf.memory.len > 0 {
        buf.memory.base.dealloc(buf.memory.len)
    }
}

public func readstart(ptr : UnsafeMutablePointer<uv_stream_t>, alloc_cb: uv_alloc_cb, read_cb: uv_read_cb) {
    uv_read_start(ptr, alloc_cb, read_cb)
}

// Stream end

// tcp wrap

public func getTcpHandle(fd :  uv_os_sock_t) -> UnsafeMutablePointer<uv_tcp_t> {
    let handle : UnsafeMutablePointer<uv_tcp_t> = UnsafeMutablePointer<uv_tcp_t>.alloc(1)
    uv_tcp_init(uv_default_loop(), handle)
    uv_tcp_open(handle, fd)
    return handle
}

public class Libuv {
    
    let fd : Int32
    var loop : uv_loop_ptr
    var handle : uv_poll_ptr
    
    // uv_poll_cb  =  @convention(c) (UnsafeMutablePointer<uv_poll_s>, Int32, Int32) -> ()
    var acceptCallback : uv_poll_cb! = nil
    var readCallback : uv_poll_cb! = nil
    var writeCallback : uv_poll_cb! = nil
    
    public init(fd : Int32, loop : uv_loop_ptr = uv_default_loop()) {
        self.fd = fd
        self.loop = loop
        self.handle = uv_poll_ptr.alloc(1)
        
//        uv_loop_init(self.loop)
        //uv_poll_init(self.loop, self.handle, self.fd)
        uv_poll_init_socket(self.loop, self.handle, self.fd)
    }
    
    deinit {
        uv_loop_close(self.loop)
        uv_poll_stop(self.handle)
    }
    
    // Testing readable / writable event
    public func runAcceptCallback() -> Bool {
        
        self.acceptCallback = {
            pollPtr, first, second in
            
            var pfd : uv_os_fd_t = uv_os_fd_t()
            uv_fileno(UnsafeMutablePointer<uv_handle_t>(pollPtr), &pfd)
            
            var caddr = IPv4()
            var caddrLen = socklen_t(caddr.length())
            
            let cfd = withUnsafeMutablePointer(&caddr) {
                ptr -> Int32 in
                let addrPtr = UnsafeMutablePointer<sockaddr>(ptr)
                
                #if os(Linux)
                    return SwiftGlibc.accept(pfd, addrPtr, &caddrLen)
                #else
                    return Darwin.accept(pfd, addrPtr, &caddrLen)
                #endif
            }
            
            let cSocket : ConnectedSocket! = ConnectedSocket(fd: cfd, address: caddr)
            
            print("New client fd : \(cfd), address : \(cSocket.address.ip())")
            
            
            let handle : UnsafeMutablePointer<uv_tcp_t> =  getTcpHandle(cfd)
            readstart(UnsafeMutablePointer<uv_stream_t>(handle), alloc_cb: alloc_buffer, read_cb: echo_read)
            
        }
        
        if let callback = self.acceptCallback {
            uv_poll_start(self.handle, Int32(UV_READABLE.rawValue), callback)
            self.runLoop()
            return true
        }
        log.error("Libuv read callback is not set. Please set the read callback before execute this function.")
        return false
    }
    
    public func runReadCallback() -> Bool {
        
        self.readCallback = {
            pollPtr, first, second in
            
            var cfd : uv_os_fd_t = uv_os_fd_t()
            uv_fileno(UnsafeMutablePointer<uv_handle_t>(pollPtr), &cfd)
            
         
           
            let handle : UnsafeMutablePointer<uv_tcp_t> =  UnsafeMutablePointer<uv_tcp_t>.alloc(1)
            uv_tcp_init(uv_default_loop(), handle)
            uv_tcp_open(handle, cfd)
            readstart(UnsafeMutablePointer<uv_stream_t>(handle), alloc_cb: alloc_buffer, read_cb: echo_read)
           
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

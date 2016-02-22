//
//  Stream.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 17..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//


import Libuv

public class Stream : Handle {
    
    public let streamHandle : uv_stream_ptr
    
    var readCallback : ((Int, uv_buf_const_ptr, uv_handle_type)->())! = nil
    
    public init (streamHandle : uv_stream_ptr){
        self.streamHandle = streamHandle
        super.init(handle: uv_handle_ptr(streamHandle))
    }
    
    deinit {
        
    }
    
    public func readStart() -> Int32 {
        return uv_read_start(self.streamHandle, Stream.onAlloc, Stream.onRead)
    }
    
    public func readStop() -> Int32 {
        return uv_read_stop(self.streamHandle)
    }
    
    public func doShutDown(request : uv_shutdown_ptr) -> Int32 {
        var error : Int32
        
        error = uv_shutdown(request, self.streamHandle, Stream.afterShutdown)
        
        return error
    }
    
    public func doTryWrite(buffer: UnsafeMutablePointer<uv_buf_ptr>, count : UnsafeMutablePointer<UInt32>) -> Int32 {
        var error : Int32
        var written : Int32
        var vbuffer : uv_buf_ptr = buffer.memory
        var vcount : UInt32 = count.memory
        
        error = uv_try_write(self.streamHandle, vbuffer, vcount)
        
        guard  (error != UV_ENOSYS.rawValue && error != UV_EAGAIN.rawValue) else {
            return 0
        }
        guard error >= 0 else {
            return error
        }
        
        written = error
        for ; vcount > 0 ; vbuffer++, vcount-- {
            
            if vbuffer[0].len > Int(written) {
                vbuffer[0].base.initialize(vbuffer[0].base[Int(written)])
                vbuffer[0].len -= Int(written)
                written = 0
                break;
            }
            else {
                written -= vbuffer[0].len;
            }
        }
        
        buffer.memory = vbuffer;
        count.memory = vcount;
        
        return 0
    }
    
}


// Stream static functions.

extension Stream {
    
    // Should be modified.
    public static func doWrite(buffer: uv_buf_const_ptr, handle : uv_stream_ptr,
        count : UInt32 = 1, sendHandle : uv_stream_ptr! = nil) -> Int {
            
        let request : uv_write_ptr = uv_write_ptr.alloc(1)
        let error : Int32
            
//        Should add request module
//        request.memory.bufs.memory = uv_buf_init(UnsafeMutablePointer<Int8>.alloc(size), UInt32(size))
//        memcpy(request.memory.bufs.memory.base, buffer.memory.base, size)

        if sendHandle != nil {
            error = uv_write2(request, handle, buffer, count, sendHandle, Stream.afterWrite)
        }
        else {
            error = uv_write(request, handle, buffer, count, Stream.afterWrite)
        }
        
        if buffer.memory.len > 0 {
            buffer.memory.base.dealloc(buffer.memory.len)
        }
        
        if error == 0 {
            // Should add count module
            
            //
        }
        
        return 1
    }
    
    public static func isReadable (handle : uv_stream_ptr) -> Bool {

       return uv_is_readable(handle) == 1
    }
    
    public static func isWritable (handle : uv_stream_ptr) -> Bool {
        
        return uv_is_writable(handle) == 1
    }
    
    public static func setBlocking (handle : uv_stream_ptr, blocking : Int32) {
        
        uv_stream_set_blocking(handle, blocking)
    }
    
    public static func isNamedPipe (handle : uv_stream_ptr) -> Bool {
        
        return handle.memory.type == UV_NAMED_PIPE
    }
    
    public static func isNamedPipeIpc (handle : uv_stream_ptr) -> Bool {
        
        return Stream.isNamedPipe(handle) && uv_pipe_ptr(handle).memory.ipc != 0
    }
    
    public static func getHandleType (handle : uv_stream_ptr) -> uv_handle_type {
        var type : uv_handle_type = UV_UNKNOWN_HANDLE
        
        if Stream.isNamedPipe(handle) && uv_pipe_pending_count(uv_pipe_ptr(handle)) > 0 {
            type = uv_pipe_pending_type(uv_pipe_ptr(handle))
        }
        
        return type
    }
}


// Stream static callbacks.

extension Stream {
    
    public static var onAlloc : uv_alloc_cb! = { (_, size, buf) in
        buf.initialize(uv_buf_init(UnsafeMutablePointer.alloc(size), UInt32(size)))
    }
    
    public typealias uv_read_com_cb = @convention(c) (uv_stream_ptr, Int, uv_buf_const_ptr, uv_handle_type) -> ()
    public static let onReadCommon : uv_read_com_cb = { (handle, nread, buf, type) in
        
        let wrap : Stream = Stream(streamHandle: uv_stream_ptr(handle.memory.data))
        // Should add count module
        
        //
        if let callback  = wrap.readCallback {
            callback(nread, buf, type)
        }
    }
    
    public static var onRead : uv_read_cb! = { (handle, nread, buf) in
        
//        let wrap : Stream = Stream(streamHandle: uv_stream_ptr(handle.memory.data))
//        var type : uv_handle_type = Stream.getHandleType(handle)
//        Stream.onReadCommon(handle, nread, buf, type)
        
        if nread < 0 {
            if Int32(nread) == UV_EOF.rawValue {
                Handle.close(uv_handle_ptr(handle))
            }
            else {
                // Should handle error in here
                
            }
        }
        else if let wrap = Handle.dictionary[uv_handle_ptr(handle)] {
            if let callback =  wrap.event.onRead {
                callback(handle , nread, buf)
            }
        }
        
    }
    
    public static var afterShutdown : uv_shutdown_cb = { (request, status) in
        // State after shutdown callback
        
    }
    
    public static var afterWrite : uv_write_cb = { (request, status) in
 
//        request.memory.bufs.memory.base.dealloc(request.memory.bufs.memory.len)
        request.dealloc(1)
    }
    
    func onAfterWriteImpl() -> Void {
        
    }
    
    func onAllocImpl() -> Void {
        
    }
    
    func onReadImpl() -> Void {
        
    }
}
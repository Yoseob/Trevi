//
//  FileStream.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 6..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public class FileSystem {

public struct Options {
    public var fd : Int32! = nil
    public var flags : Int32! = nil
    public var mode : Int32! = nil
}
    
    
public static func close(handle : uv_handle_ptr) {
    
    let info = UnsafeMutablePointer<FSInfo>(handle.memory.data)
    let request = info.memory.request
    let loop = info.memory.loop
    
    Handle.close(handle)
    FSBase.close(loop, request: request)
    Loop.close(loop)
    request.dealloc(1)
    info.dealloc(1)
}
    
    
// Should be inherited from StreamReadable

public class ReadStream {
    
    public let loop : Loop
    public let pipe : Pipe
    public var options : Options = Options()
    
    public init(path : String, options : Options? = nil) {
        
        self.loop = Loop()
        self.pipe = Pipe(loop: loop.loopHandle)
        self.options.flags = O_RDONLY
        self.options.mode = 0o666
        
        if let options = options { self.setOptions(options) }
        
        
        if self.options.fd == nil {
            self.options.fd = FSBase.open(self.loop.loopHandle, handle: self.pipe.pipeHandle, path : path,
                flags: self.options.flags, mode: self.options.mode)
        }
        
        if self.options.fd <= 0 {
            // Should handle error
            
            print("Read Stream file open error \(self.options.fd)")
        }
        else{
            Pipe.open(self.pipe.pipeHandle, fd: self.options.fd)
            
            self.pipe.event.onClose = { (handle) in
                
                FileSystem.close(handle)
            }
        }
    }
    deinit{
        Handle.close(self.pipe.handle)
    }
    
    func setOptions(options : Options) {
        self.options.fd = options.fd
        self.options.flags = options.flags == nil ? O_RDONLY : options.flags
        self.options.mode = options.mode == nil ?  0o666 : options.mode
    }
    
    public func onClose(callback : ((handle : uv_handle_ptr)->Void)) {
        
        self.pipe.event.onClose = { (handle) in
        
            callback(handle: handle)
            FileSystem.close(handle)
        }
    }
    
    
    public func readStart(callback : ((error : Int32, data : NSData)->Void)) {
        
        self.pipe.event.onRead = { (handle, data) in
            
            let info = UnsafeMutablePointer<FSInfo>(handle.memory.data)
            info.memory.toRead = info.memory.toRead - UInt64(data.length)
            
            callback(error : 0, data : data)
            
            if info.memory.toRead <= 0 {
                Handle.close(uv_handle_ptr(handle))
            }
        }
        
        Stream.readStart(self.pipe.streamHandle)
    }
    
    
    public func pipeStream(writeStream : WriteStream) {
        
        self.onClose() {
            handle in
            Handle.close(writeStream.pipe.handle)
        }
        
        self.readStart() {
            (error, data) in
            writeStream.writeData(data)
        }
        
        Loop.run(self.loop.loopHandle, mode: UV_RUN_ONCE)
        Loop.run(writeStream.loop.loopHandle, mode: UV_RUN_ONCE)
    }
    
}
    
    
// Should be inherited from StreamReadable
    
public class WriteStream {
    
    public let loop : Loop
    public let pipe : Pipe 
    public var options : Options = Options()
    
    public init(path : String, options : Options? = nil) {
        
        self.loop = Loop()
        self.pipe = Pipe(loop: loop.loopHandle)
        self.options.flags = O_CREAT | O_WRONLY
        self.options.mode = 0o666
        
        if let options = options { self.setOptions(options) }
        
        if self.options.fd == nil {
            self.options.fd = FSBase.open(self.loop.loopHandle, handle: self.pipe.pipeHandle, path : path,
                flags: self.options.flags, mode: self.options.mode)
        }
        
        if self.options.fd <= 0 {
            // Should handle error
            
            print("Write Stream file open error \(self.options.fd)")
        }
        else{
            
            Pipe.open(self.pipe.pipeHandle, fd: self.options.fd)
            
            self.pipe.event.onClose = { (handle) in
                
                FileSystem.close(handle)
            }
        }
    }
    deinit {
        Handle.close(self.pipe.handle)
    }
    
    
    func setOptions(options : Options) {
        self.options.fd = options.fd
        self.options.flags = options.flags == nil ? O_CREAT | O_WRONLY : options.flags
        self.options.mode = options.mode == nil ?  0o666 : options.mode
    }
    
    
    public func close() {
        Handle.close(self.pipe.handle)
    }
    
    
    public func writeData(data : NSData) {
        
        Stream.doWrite(data, handle: self.pipe.streamHandle)
    }
    
}

}

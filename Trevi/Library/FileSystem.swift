//
//  FileStream.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 6..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation

/**
Filesystem library for Trevi and Trevi developers.
Only provides File readable, writable stream module yet.
 */
public class FileSystem {
    
    public struct Options {
        public var fd : Int32! = nil
        public var flags : Int32! = nil
        public var mode : Int32! = nil
    }
    
    
    // Close the File descriptor on system and all libuv handle events.
    // Also, dealloc all memory associated with the handle.
    public static func close(handle : uv_handle_ptr) {
        
        let info = UnsafeMutablePointer<FSInfo>(handle.memory.data)
        let request = info.memory.request
        let loop = info.memory.loop
        
        Handle.close(handle)
        FSBase.close(loop, request: request)
        info.dealloc(1)
    }
    
    
    // Should be inherited from StreamReadable
    public class ReadStream {
        
        public let loop : Loop
        public let pipe : Pipe
        public var options : Options = Options()
        
        public init?(path : String, options : Options? = nil) {
            
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
                LibuvError.printState("FileSystem.ReadStream init", error : self.options.fd)
                return nil
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
            Loop.close(self.loop.loopHandle)
        }
        
        
        func setOptions(options : Options) {
            self.options.fd = options.fd
            self.options.flags = options.flags == nil ? O_RDONLY : options.flags
            self.options.mode = options.mode == nil ?  0o666 : options.mode
        }
        
        
        // Set ReadStream pipe onClose event.
        // It should be called before readstart.
        public func onClose(callback : ((handle : uv_handle_ptr)->Void)) {
            
            self.pipe.event.onClose = { (handle) in
                
                callback(handle: handle)
                FileSystem.close(handle)
            }
        }
        
        // Set ReadStream pipe onRead event and start loop.
        // Other events associated with this pipe handle should be set before call this function.
        public func readStart(callback : ((error : Int32, data : NSData)->Void)) {
            
            self.pipe.event.onRead = { (handle, data) in
                
                let info = UnsafeMutablePointer<FSInfo>(handle.memory.data)
                info.memory.toRead = info.memory.toRead - UInt64(data.length)
                
                callback(error : 0, data : data)
                
                // Close readStream when there are no more data to read.
                if info.memory.toRead <= 0 {
                    Handle.close(uv_handle_ptr(handle))
                }
            }
            
            Stream.readStart(self.pipe.streamHandle)
            Loop.run(self.loop.loopHandle, mode: UV_RUN_DEFAULT)
        }
        
        
        // Pipe data directly to writeStream.
        // Close readStream and writeStream after finish read data.
        public func pipeStream(writeStream : WriteStream) {
            
            self.onClose() { (handle) in
                
                Handle.close(writeStream.pipe.handle)
            }
            
            self.readStart() { (error, data) in
                
                writeStream.writeData(data)
            }
            
            Loop.run(writeStream.loop.loopHandle, mode: UV_RUN_DEFAULT)
        }
        
    }
    
    
    // Should be inherited from StreamReadable
    
    public class WriteStream {
        
        public let loop : Loop
        public let pipe : Pipe
        public var options : Options = Options()
        
        public init?(path : String, options : Options? = nil) {
            
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
                LibuvError.printState("FileSystem.WriteStream init", error : self.options.fd)
                return nil
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
            Loop.close(self.loop.loopHandle)
        }
        
        
        func setOptions(options : Options) {
            self.options.fd = options.fd
            self.options.flags = options.flags == nil ? O_CREAT | O_WRONLY : options.flags
            self.options.mode = options.mode == nil ?  0o666 : options.mode
        }
        
        
        public func close() {
            
            FileSystem.close(self.pipe.handle)
        }
        
        
        public func writeData(data : NSData) {
            
            Stream.doWrite(data, handle: self.pipe.streamHandle)
        }
        
    }
    
}

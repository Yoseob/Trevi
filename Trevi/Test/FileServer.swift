//
//  FileServer.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 3..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation


public class FileServer {
    
    let readPipe = Pipe()
    let writePipe = Pipe()
    
    
    public func readStart(path : String) {
        
        FileServer.setFileStreamEvents(self.readPipe, self.writePipe)
        FsBase.streamReadFile(self.readPipe.pipeHandle, path: path)
    }
    
}


// FileServer static functions

extension FileServer {
    
    
    // Temporary function for testing FsBase module. 
    // Should be modified.
    public static func setFileStreamEvents(readPipe : Pipe, _ writePipe : Pipe){
        
        FsBase.streamOpenFile(writePipe.pipeHandle, path: "/Users/Ingyure/Documents/fswritetest.txt")
        
        readPipe.event.onRead = { (handle, data) in
            
            print("Read : \(data.length)")
            
            let infoPtr = UnsafeMutablePointer<FsBase.Info>(handle.memory.data)
            
            infoPtr.memory.nread += data.length
            
            if infoPtr.memory.nread == Int(infoPtr.memory.size) {
                
                FsBase.close(infoPtr.memory.request)
                Handle.close(uv_handle_ptr(handle))
            }
            
            if data.length > 0 {
                
                FsBase.streamWriteFile(writePipe.pipeHandle, data: data)
            }
            
        }
        
        readPipe.event.onClose = { (handle) in
            print("File pipe cloesing")
            
        }
    }
}
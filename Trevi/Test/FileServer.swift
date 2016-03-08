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
    
    public init(){
        print("init")
    }
    deinit{
        print("deinit")
    }
    
    public func fileTestStart() {
        
        let readableStream = FileSystem.ReadStream(path: "/Users/Ingyure/Documents/testImage1.jpg")
        let writableStream = FileSystem.WriteStream(path: "/Users/Ingyure/Documents/testImage2.jpg")
        
        readableStream.pipeStream(writableStream)
    }
    
}
//
//  ServeStatic.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 27..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
/**
 A Middleware for serving static files in server like .css, .js, .html, etc.
 */

public class ServeStatic: Middleware {
    
    public var name: MiddlewareName
    private let basePath: String
    
    public init (path: String) {
        name = .ServeStatic
        
        if let last = path.characters.last where last == "/" {
            basePath = path[path.startIndex ..< path.endIndex.advancedBy(-1)]
        } else {
            basePath = path
        }
    }
    
    
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        
        var entirePath = req.url
        #if os(Linux)
            entirePath = "\(basePath)/\(req.url)"
        #else
            if let bundlePath = NSBundle.mainBundle().pathForResource(NSURL(fileURLWithPath: req.url).lastPathComponent!, ofType: nil) {
                entirePath = bundlePath
            }
        #endif
        
        let file = ReadableFile(fileAtPath: entirePath)
        if file.isExist() && (file.type == FileType.Regular || file.type == FileType.SymbolicLink) {
            var buffer = [UInt8](count: 8, repeatedValue: 0)
            let data = NSMutableData()
            
            file.open()
            while file.status == .Open {
                let result: Int = file.read(&buffer, maxLength: buffer.count)
                data.appendBytes(buffer, length: result)
            }
            return res.send(data)
        }
        next!()
    }
    

}

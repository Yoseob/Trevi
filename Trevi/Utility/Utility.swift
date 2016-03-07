//
//  Utility.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public func executeShellCommand(command: String, args: [String]? = nil) -> String? {
    let task = NSTask ()
    let pipe = NSPipe ()
    
    task.launchPath = command
    task.standardOutput = pipe
    if args != nil {
        task.arguments = args
    }
    
    task.launch()
    
    return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)
}

public func getCurrentDatetime(format: String = "yyyy/MM/dd hh:mm:ss a z") -> String {
    let formatter = NSDateFormatter()
    formatter.dateFormat = format
    return formatter.stringFromDate(NSDate())
}

public func bridge<T : AnyObject>(obj : T) -> UnsafePointer<Void> {
    return UnsafePointer(Unmanaged.passUnretained(obj).toOpaque())
    // return unsafeAddressOf(obj) // ***
}

public func bridge<T : AnyObject>(ptr : UnsafePointer<Void>) -> T {
    return Unmanaged<T>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue()
    // return unsafeBitCast(ptr, T.self) // ***
}
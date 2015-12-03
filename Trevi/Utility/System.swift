//
//  System.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

class System {
    
    static func executeCmd(command: String) -> String {
        return executeCmd(command, args: [])
    }
    
    static func executeCmd(command: String, args: [String]) -> String {
        let task = NSTask()
        let pipe = NSPipe()
        
        task.launchPath = command
        task.arguments = args
        task.standardOutput = pipe
        task.launch()
        
        return (NSString(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: NSUTF8StringEncoding) as String?)!
    }
    
}
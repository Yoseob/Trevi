//
//  FileIO.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

class FileIO {
    
    // Reading
    static func read(filePath: String, encoding: UInt = NSUnicodeStringEncoding) -> String {
        let contents: String?
        do {
            contents = try String(contentsOfFile: filePath, encoding: encoding)
        } catch let error as NSError {
            print("Error loading from url \(filePath)")
            print(error.localizedDescription)
            contents = ""
        }
        return contents!
    }
    
    // Writing
    static func write(filePath: String, data: String, encoding: UInt = NSUnicodeStringEncoding) {
        do {
            try data.writeToFile(filePath, atomically: false, encoding: encoding)
            //            try data.writeToFile(filePath, atomically: false)
        } catch let error as NSError {
            print("error loading from url \(filePath)")
            print(error.localizedDescription)
        }
    }
    
}
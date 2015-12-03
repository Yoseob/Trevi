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
    static func read(filePath: String) -> String {
        let contents: String?
        do {
            contents = try String(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
        } catch let error as NSError {
            print("Error loading from url \(filePath)")
            print(error.localizedDescription)
            contents = ""
        }
        return contents!
    }
    
    // Writing
    static func write(filePath: String, data: String) {
        do {
            try data.writeToFile(filePath, atomically: false, encoding: NSUTF8StringEncoding)
            //            try data.writeToFile(filePath, atomically: false)
        } catch let error as NSError {
            print("error loading from url \(filePath)")
            print(error.localizedDescription)
        }
    }
    
}
//
//  FileIO.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum FileError: ErrorType {
    case FileOpenError( msg:String )
}

class File {

    // Reading
    static func read ( filePath: String, encoding: UInt = NSUTF8StringEncoding ) throws -> String {
        do {
            let contents = try String ( contentsOfFile: filePath, encoding: encoding )
            return contents
        } catch {
            let ioError = error as NSError
            throw FileError.FileOpenError ( msg: ioError.localizedDescription )
        }
    }

    // Writing
    static func write ( filePath: String, data: String, encoding: UInt = NSUTF8StringEncoding ) throws {
        do {
            try data.writeToFile ( filePath, atomically: false, encoding: encoding )
        } catch {
            let ioError = error as NSError
            throw FileError.FileOpenError ( msg: ioError.localizedDescription )
        }
    }

}
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

public class File {

    
    let filemgr = NSFileManager.defaultManager()
    
    public func createFile(path : String){
        filemgr.createFileAtPath(path, contents: nil, attributes: nil)
    }
    
    public func existsFile(path : String){
    
        if filemgr.fileExistsAtPath(path) {
            print("File exists")
        } else {
            print("File not found")
        }
    }
    func removeFile(path:String){
        do {
            try filemgr.removeItemAtPath(path)
        } catch {
            let ioError = error as NSError
            FileError.FileOpenError ( msg: ioError.localizedDescription )
        }
    }
    
    func write(filePath: String, data: String, encoding: UInt = NSUTF8StringEncoding ){
        let file: NSFileHandle? = NSFileHandle(forUpdatingAtPath: filePath)
        if file != nil {
           writeImpliment(file!, data: data, encoding: encoding)
        } else {
            createFile(filePath)
            writeImpliment(NSFileHandle(forUpdatingAtPath: filePath)!, data: data, encoding: encoding)
        }
    }
    
    func read(filePath: String, encoding: UInt = NSUTF8StringEncoding ) -> String {
        let file: NSFileHandle? = NSFileHandle(forReadingAtPath: filePath)
        return String(data: (file?.readDataToEndOfFile())!, encoding: encoding)!
    }
    
    private func writeImpliment(file: NSFileHandle, data: String, encoding: UInt = NSUTF8StringEncoding ){
        file.seekToEndOfFile()
        let data = (data as NSString).dataUsingEncoding(encoding)
        file.writeData(data!)
        file.closeFile()
    }
    
    func closeFile(){
        
    }
    // Reading
    static func read(filePath: String, encoding: UInt = NSUTF8StringEncoding ) throws -> String {
        do {
            let contents = try String ( contentsOfFile: filePath, encoding: encoding )
            return contents
        } catch {
            let ioError = error as NSError
            throw FileError.FileOpenError ( msg: ioError.localizedDescription )
        }
    }

    // Writing
    static func write(filePath: String, data: String, encoding: UInt = NSUTF8StringEncoding ) throws {
        do {
            try data.writeToFile ( filePath, atomically: false, encoding: encoding )
        } catch {
            let ioError = error as NSError
            throw FileError.FileOpenError ( msg: ioError.localizedDescription )
        }
    }
    
    

}
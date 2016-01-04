//
//  FileIO.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum FileError: ErrorType {
    case ReadingError( msg:String )
    case WritingError( msg:String )
    case TypeConvertError( msg:String )
}

public class File {
    
    /**
     Returns a data object initialized by reading into it the data from the file specified by a given path.
     A data object initialized by reading into it the data from the file specified by path.
     
     - Parameter path: The name of the file or path of the file from which to read data.
     - Parameter option: A mask that specifies options for reading the data. Constant components are described in “NSDataReadingOptions”.
     
     - Throws: `FileError.ReadingError` if can't open the file specified by `path`.
     
     - Returns: A data object initialized by reading into it the data from the file specified by path.
     */

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
//            let ioError = error as NSError
//            FileError.FileOpenError ( msg: ioError.localizedDescription )
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
    
        static func read ( from path: String, option: NSDataReadingOptions = [] ) throws -> NSData {
        do {
            let contents = try NSData( contentsOfFile: path, options: option )
            return contents
        } catch {
            let ioError = error as NSError
            throw FileError.ReadingError ( msg: ioError.localizedDescription )
        }
    }

    /**
     Writes the bytes in the receiver to the file specified by a given path.
     
     - Parameter data: The data to be written.
     - Parameter path: The location to which to write the receiver's bytes.
     - Parameter options: A mask that specifies options for writing the data. Constant components are described in “NSDataWritingOptions”.
     
     - Throws: `FileError.WritingError` if can't write the data on the file specified by `path`.
     */
    static func write ( data: NSData, to path: String, option: NSDataWritingOptions = [] ) throws {
        do {
            try data.writeToFile( path, options: option )
        } catch {
            let ioError = error as NSError
            throw FileError.WritingError ( msg: ioError.localizedDescription )
        }
    }
    
    /**
     Writes the string data with encoding in the receiver to the file specified by a given path.
     
     - Parameter data: The data to be written.
     - Parameter path: The location to which to write the receiver's bytes.
     - Parameter encoding: An encoding for encode data.
     - Parameter options: A mask that specifies options for writing the data. Constant components are described in “NSDataWritingOptions”.
     
     - Throws:
        - `FileError.TypeConvertError` if can't convert the data to String with encoding.
        - `FileError.WritingError` if can't write the data on the file specified by `path`.
     */
    static func write ( data: String, to path: String, encoding: NSStringEncoding, option: NSDataWritingOptions = [] ) throws {
        guard let converted = data.dataUsingEncoding( encoding ) else {
            throw FileError.TypeConvertError ( msg: "Unable converting to NSData with \(encoding)" )
        }
        
        do {
            try converted.writeToFile( path, options: option )
        } catch {
            let ioError = error as NSError
            throw FileError.WritingError ( msg: ioError.localizedDescription )
        }
    }
    
    // Get real path from bundle file
    
    /**
    Returns the full pathname for the resource identified by the path. The full pathname for the resource file.
    
    - Parameter path: The name of the file or path of the file from which to read data.
    
    - Returns: The full pathname for the resource file.
    */
    static func getRealPath( path : String ) -> String {
        
        let _path: String!;
        if path.characters.last == "/" {
            _path = path[ path.startIndex ..< path.endIndex.advancedBy(-1) ]
        } else {
            _path = path
        }
        
        guard let filename = _path.componentsSeparatedByString( "/" ).last else {
            return path
        }
        let nameElement = filename.componentsSeparatedByString( "." )
        if nameElement.count == 2 {
            guard let bundlePath = NSBundle.mainBundle().pathForResource( nameElement[0], ofType: nameElement.count > 1 ? nameElement[1] : "" ) else {
                return path
            }
            return bundlePath
        } else {
            return path
        }
    }

}
//
//  FileIO.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

public enum FileError: ErrorType {
    case ReadingError( msg:String )
    case WritingError( msg:String )
    case TypeConvertError( msg:String )
}

public class File {
    
    private static let BUFSIZE = 1024
    
    /**
     Returns the full pathname for the resource identified by the path. The full pathname for the resource file.
     
     - Parameter path: The name of the file or path of the file from which to read data.
     
     - Returns: The full pathname for the resource file.
     */
    public static func getRealPath ( path : String ) -> String {
        
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
    
    // On success (all requested permissions granted), zero is returned.
    // On error (at least one bit in mode asked for a permission that is denied, or some other error occurred), -1 is returned, and errno is set appropriately.
    public static func isExist ( path : String ) -> Bool {
        #if os(Linux)
            if Glibc.access( path, F_OK ) == 0 {
                return true     // exists
            } else {
                return false    // not found
            }
        #else
            if Darwin.access( path, F_OK ) == 0 {
                return true     // exists
            } else {
                return false    // not found
            }
        #endif
    }
    
    public static func create ( path : String ) -> Bool {
        #if os(Linux)
            let fd = Glibc.open(path, O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
        #else
            let fd = Darwin.open(path, O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
        #endif
        if fd == -1 {
            print( "ERROR : File create failed" )
            return false
        }
        close (fd);
        return true
    }
    
    // On success, zero is returned. On error, -1 is returned, and errno is set appropriately.
    public static func remove( path : String ) -> Int32 {
        #if os(Linux)
            return Glibc.remove( path )
        #else
            return Darwin.remove( path )
        #endif
    }
    
    public static func read ( filePath: String, option: Int32 = O_RDONLY ) -> NSData? {
        
        let fd = open( filePath, option|O_RDONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
        if fd == -1 {
            print( "ERROR : File open failed" )
            return nil
        }
        
        let buf = UnsafeMutablePointer<Int8>.alloc(BUFSIZE)
        var data = NSMutableData();
        
        #if os(Linux)
            var readn = Glibc.read(fd, buf, BUFSIZE)
            while readn > 0 {
                data.appendBytes(buf, length: readn)
                readn = Glibc.read(fd, buf, BUFSIZE)
            }
        #else
            var readn = Darwin.read(fd, buf, BUFSIZE)
            while readn > 0 {
                data.appendBytes(buf, length: readn)
                readn = Darwin.read(fd, buf, BUFSIZE)
            }
        #endif
        
        // Close file
        close (fd);
        
        return data
    }
    
    public static func write ( filePath: String, data: UnsafePointer<Void>, size: Int, var option: Int32 = O_WRONLY ) -> Bool {
        
        #if os(Linux)
            if Glibc.access( filePath, F_OK ) != 0 {
                option |= O_CREAT
            }
            
            let fd = Glibc.open( filePath, option|O_WRONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
            if fd == -1 {
                print( "ERROR : File open failed" )
                return false
            }
            
            if size == Glibc.write( fd, data, size ) {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access( filePath, F_OK ) != 0 {
                option |= O_CREAT
            }
            
            let fd = Darwin.open( filePath, option|O_WRONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
            if fd == -1 {
                print( "ERROR : File open failed" )
                return false
            }
            
            if size == Darwin.write( fd, data, size ) {
                return true
            } else {
                return false
            }
        #endif
    }
}
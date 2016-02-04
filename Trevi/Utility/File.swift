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

public enum FileType {
    case RegularFile
    case Directory
    case CharacterDevice
    case BlockDevice
    case FIFO
    case SymbolicLink
    case Socket
    case Unknown
}

public class File {
    
    private static let BUFSIZE = 1024
    
    /**
     Returns the full pathname for the resource identified by the path. The full pathname for the resource file.
     
     - Parameter path: The name of the file or path of the file from which to read data.
     
     - Returns: The full pathname for the resource file.
     */
    public static func getResourcePath ( path : String ) -> String {
        let comp = path.componentsSeparatedByString( "/" )
        if let rsrcPath = NSBundle.mainBundle().pathForResource( comp.last!, ofType: nil ) {
            return rsrcPath
        }
        return path
    }
    
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
    
    public static func isReadable ( path : String ) -> Bool {
        #if os(Linux)
            if Glibc.access( path, R_OK ) == 0 {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access( path, R_OK ) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public static func isWritable ( path : String ) -> Bool {
        #if os(Linux)
            if Glibc.access( path, W_OK ) == 0 {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access( path, W_OK ) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public static func isExecutable ( path : String ) -> Bool {
        #if os(Linux)
            if Glibc.access( path, X_OK ) == 0 {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access( path, X_OK ) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public static func getType ( path : String ) -> FileType? {
        let path_stat = UnsafeMutablePointer<stat>.alloc(1)
        
        #if os(Linux)
            if Glibc.stat(path, path_stat) == -1 {
                print( "ERROR : File type check failed" )
                return nil
            }        #else
            if Darwin.stat(path, path_stat) == -1 {
                print( "ERROR : File type check failed" )
                return nil
            }
        #endif
        
        switch path_stat.memory.st_mode & S_IFMT {
        case S_IFREG: return FileType.RegularFile
        case S_IFDIR: return FileType.Directory
        case S_IFBLK: return FileType.BlockDevice
        case S_IFCHR: return FileType.CharacterDevice
        case S_IFIFO: return FileType.FIFO
        case S_IFLNK: return FileType.SymbolicLink
        case S_IFSOCK: return FileType.Socket
        default: return FileType.Unknown
        }
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
    
    /**
     - Returns: On success, zero is returned. On error, -1 is returned, and errno is set appropriately.
     */
    public static func remove( path : String ) -> Int32 {
        #if os(Linux)
            return Glibc.remove( path )
        #else
            return Darwin.remove( path )
        #endif
    }
    
    public static func read ( filePath: String, option: Int32 = O_RDONLY ) -> NSData? {
        #if os(Linux)
            if Glibc.access( filePath, R_OK ) == -1 {
                return nil
            }
            
            let buf = UnsafeMutablePointer<Int8>.alloc(BUFSIZE)
            var data = NSMutableData();
            
            let fd = open( filePath, option|O_RDONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
            if fd == -1 {
                print( "ERROR : File open failed" )
                return nil
            }
            
            var readn = Glibc.read(fd, buf, BUFSIZE)
            while readn > 0 {
                data.appendBytes(buf, length: readn)
                readn = Glibc.read(fd, buf, BUFSIZE)
            }
            
            Glibc.close(fd);
        #else
            if Darwin.access( filePath, R_OK ) == -1 {
                return nil
            }
            
            let buf = UnsafeMutablePointer<Int8>.alloc(BUFSIZE)
            let data = NSMutableData();
            
            let fd = open( filePath, option|O_RDONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
            if fd == -1 {
                print( "ERROR : File open failed" )
                return nil
            }
            
            var readn = Darwin.read(fd, buf, BUFSIZE)
            while readn > 0 {
                data.appendBytes(buf, length: readn)
                readn = Darwin.read(fd, buf, BUFSIZE)
            }
            
            Darwin.close(fd);
        #endif
        
        return data
    }
    
    public static func write ( filePath: String, data: UnsafePointer<Void>, size: Int, var option: Int32 = O_WRONLY ) -> Bool {
        #if os(Linux)
            if Glibc.access( filePath, F_OK ) != 0 {
                option |= O_CREAT
            } else if Glibc.access( filePath, W_OK ) != 0 {
                return false
            }
            
            let fd = Glibc.open( filePath, option|O_WRONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
            if fd == -1 {
                print( "ERROR : File open failed" )
                return false
            }
            
            let written = Glibc.write( fd, data, size )
            
            Glibc.close(fd);
        #else
            if Darwin.access( filePath, F_OK ) != 0 {
                option |= O_CREAT
            } else if Darwin.access( filePath, W_OK ) != 0 {
                return false
            }
            
            let fd = Darwin.open( filePath, option|O_WRONLY, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
            if fd == -1 {
                print( "ERROR : File open failed" )
                return false
            }
            
            let written = Darwin.write( fd, data, size )
            
            Darwin.close(fd);
        #endif
        
        if size == written {
            return true
        } else {
            return false
        }
    }
}
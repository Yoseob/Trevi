//
//  File.swift
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

public enum FileType: String {
    case Regular = "FileTypeRegular"
    case Directory = "FileTypeDirectory"
    case CharacterDevice = "FileTypeCharacterDevice"
    case BlockDevice = "FileTypeBlockDevice"
    case FIFO = "FileTypeFIFO"
    case SymbolicLink = "FileTypeSymbolicLink"
    case Socket = "FileTypeSocket"
    case Unknown = "FileTypeUnknown"
}

/**
 Returns the full pathname for the resource identified by the path. The full pathname for the resource file.
 
 - Parameter path: The name of the file or path of the file from which to read data.
 
 - Returns: The full pathname for the resource file.
 */
public func getResourcePath(path: String) -> String {
    let comp = path.componentsSeparatedByString( "/" )
    if let rsrcPath = NSBundle.mainBundle().pathForResource(comp.last!, ofType: nil) {
        return rsrcPath
    }
    return path
}

public class File {
    let path: String
    let type: FileType
    private var option: Int32
    private var fd: Int32
    private let bufSize: Int
    private let buf: UnsafeMutablePointer<Int8>
    
    init (path: String, bufSize: Int = 255, option: Int32 = O_RDWR) {
        self.path = path
        self.option = option
        self.fd = -1
        self.bufSize = bufSize
        self.buf = UnsafeMutablePointer<Int8>.alloc(bufSize)
        
        // set file type
        var s = stat()
        #if os(Linux)
            if Glibc.stat(path, &s) == 0 {
                switch s.st_mode & S_IFMT {
                case S_IFREG: type = FileType.Regular
                case S_IFDIR: type = FileType.Directory
                case S_IFBLK: type = FileType.BlockDevice
                case S_IFCHR: type = FileType.CharacterDevice
                case S_IFIFO: type = FileType.FIFO
                case S_IFLNK: type = FileType.SymbolicLink
                case S_IFSOCK: type = FileType.Socket
                default: type = FileType.Unknown
                }
            } else {
                type = FileType.Unknown
            }
        #else
            if Darwin.stat(path, &s) == 0 {
                switch s.st_mode & S_IFMT {
                case S_IFREG: type = FileType.Regular
                case S_IFDIR: type = FileType.Directory
                case S_IFBLK: type = FileType.BlockDevice
                case S_IFCHR: type = FileType.CharacterDevice
                case S_IFIFO: type = FileType.FIFO
                case S_IFLNK: type = FileType.SymbolicLink
                case S_IFSOCK: type = FileType.Socket
                default: type = FileType.Unknown
                }
            } else {
                type = FileType.Unknown
            }
        #endif
    }
    
    deinit {
        if !isClosed() {
            close()
        }
    }
    
    final func isClosed() -> Bool {
        return fd < 0 ? true : false
    }
    
    final func isExist() -> Bool {
        #if os(Linux)
            if Glibc.access(path, F_OK) == 0 {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access(path, F_OK) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    final func open() -> File? {
        if !isClosed() {
            print("ERROR : File alreay opened")
            return nil
        }
        
        #if os(Linux)
            fd = Glibc.open(path, option, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
        #else
            fd = Darwin.open(path, option, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH);
        #endif
        if fd == -1 {
            print("ERROR : File open failed")
            return nil
        }
        return self
    }
    
    final func close() -> File? {
        if isClosed() {
            print("ERROR : File alreay closed : \(fd)")
            return nil
        }
        
        #if os(Linux)
            if Glibc.close(fd) == 0 {
                fd = -1
                return self
            } else {
                return nil
            }
        #else
            if Darwin.close(fd) == 0 {
                fd = -1
                return self
            } else {
                return nil
            }
        #endif
    }
    
    /**
     - Returns: On success, zero is returned. On error, -1 is returned, and errno is set appropriately.
     */
    final func remove() -> Int32 {
        #if os(Linux)
            return Glibc.remove(path)
        #else
            return Darwin.remove(path)
        #endif
    }
}

public class Readable: File {
    private var readEnd: Bool = false
    
    override init(path: String, bufSize: Int = 255, option: Int32 = O_RDONLY) {
        super.init(path: path, bufSize: bufSize, option: option|O_RDONLY&(~(O_WRONLY|O_RDWR)))
    }
    
    public func isReadable() -> Bool {
        #if os(Linux)
            if Glibc.access(path, R_OK) == 0 {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access(path, R_OK) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public final func read(option: Int32 = O_RDONLY) -> NSData? {
        if isClosed() {
            print("ERROR: File not opened")
            return nil
        }
        if !isReadable() {
            print("ERROR: File is not writable")
            return nil
        }
        
        #if os(Linux)
            let readn = Glibc.read(fd, buf, bufSize)
        #else
            let readn = Darwin.read(fd, buf, bufSize)
        #endif
        if readn > 0 {
            return NSData(bytesNoCopy: buf, length: readn)
        } else {
            return nil
        }
    }
    
    public final func readAll() -> NSData? {
        if isClosed() {
            print("ERROR: File not opened")
            return nil
        }
        if !isReadable() {
            print("ERROR: File is not writable")
            return nil
        }
        
        let data = NSMutableData();
        #if os(Linux)
            var readn = Glibc.read(fd, buf, bufSize)
            while readn > 0 {
                data.appendBytes(buf, length: readn)
                readn = Glibc.read(fd, buf, bufSize)
            }
        #else
            var readn = Darwin.read(fd, buf, bufSize)
            while readn > 0 {
                data.appendBytes(buf, length: readn)
                readn = Darwin.read(fd, buf, bufSize)
            }
        #endif
        
        return data
    }
}

public class Writable: File {
    
    override init(path: String, bufSize: Int = 255, option: Int32 = O_WRONLY) {
        super.init(path: path, bufSize: bufSize, option: option|O_WRONLY&(~(O_RDONLY|O_RDWR)))
    }
    
    public func isWritable() -> Bool {
        #if os(Linux)
            if Glibc.access(path, W_OK) == 0 {
                return true
            } else {
                return false
            }
        #else
            if Darwin.access(path, W_OK) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public final func write (data: UnsafePointer<Void>, size: Int) -> Int {
        if isClosed() {
            print("ERROR: File not opened")
            return 0
        }
        if !isWritable() {
            print("ERROR: File is not writable")
            return 0
        }
        
        #if os(Linux)
            let written = Glibc.write(fd, data, size)
        #else
            let written =  Darwin.write(fd, data, size)
        #endif
        return written
    }
}
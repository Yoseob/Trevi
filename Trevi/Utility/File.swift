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

public enum FileStatus : UInt {
    case NotOpen
    case Opening
    case Open
    case Reading
    case Writing
    case AtEnd
    case Closed
    case Error
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
    public let path: String
    public let type: FileType
    public var status: FileStatus!
    
    private var option: Int32
    private var fd: Int32
    
    init (fileAtPath: String, option: Int32 = O_RDWR) {
        self.path = fileAtPath
        self.option = option
        self.fd = -1
        
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
    
    public func isClosed() -> Bool {
        return fd < 0 ? true : false
    }
    
    public func isExist() -> Bool {
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
    
    public func open() -> File? {
        status = .Opening
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
            status = .NotOpen
            return nil
        }
        
        status = .Open
        return self
    }
    
    public func close() -> File? {
        if isClosed() {
            print("ERROR : File alreay closed")
            return nil
        }
        
        #if os(Linux)
            if Glibc.close(fd) == 0 {
                fd = -1
                status = .Closed
                return self
            } else {
                return nil
            }
        #else
            if Darwin.close(fd) == 0 {
                fd = -1
                status = .Closed
                return self
            } else {
                return nil
            }
        #endif
    }
    
    /**
     - Returns: On success, zero is returned. On error, -1 is returned, and errno is set appropriately.
     */
    public func remove() -> Int32 {
        #if os(Linux)
            return Glibc.remove(path)
        #else
            return Darwin.remove(path)
        #endif
    }
}

public class ReadableFile: File {
    private var readEnd: Bool = false
    
    override init(fileAtPath path: String, option: Int32 = O_RDONLY) {
        super.init(fileAtPath: path, option: option|O_RDONLY&(~(O_WRONLY|O_RDWR)))
    }
    
    public func isReadable() -> Bool {
        #if os(Linux)
            if fd > -1 && Glibc.access(path, R_OK) == 0 {
                return true
            } else {
                return false
            }
        #else
            if fd > -1 && Darwin.access(path, R_OK) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public override func open() -> ReadableFile {
        super.open()
        return self
    }
    
    public func read(buffer: UnsafeMutablePointer<UInt8>, maxLength len: Int) -> Int {
        if isClosed() {
            print("ERROR: Not opened")
            return -1
        }
        if !isReadable() {
            print("ERROR: Not readable")
            return -1
        }
        
        status = .Reading
        #if os(Linux)
            let readn = Glibc.read(fd, buffer, len)
        #else
            let readn = Darwin.read(fd, buffer, len)
        #endif
        if readn == 0 {
            status = .AtEnd
        } else if readn > 0 {
            status = .Open
        } else {
            status = .Error
        }
        return readn
    }
}

public class WritableFile: File {
    
    override init(fileAtPath path: String, option: Int32 = O_WRONLY) {
        super.init(fileAtPath: path, option: option|O_WRONLY&(~(O_RDONLY|O_RDWR)))
    }
    
    public func isWritable() -> Bool {
        #if os(Linux)
            if fd > -1 && Glibc.access(path, W_OK) == 0 {
                return true
            } else {
                return false
            }
        #else
            if fd > -1 && Darwin.access(path, W_OK) == 0 {
                return true
            } else {
                return false
            }
        #endif
    }
    
    public override func open() -> WritableFile {
        super.open()
        return self
    }
    
    public func write(buffer: UnsafePointer<UInt8>, maxLength len: Int) -> Int {
        if isClosed() {
            print("ERROR: Not opened")
            return 0
        }
        if !isWritable() {
            print("ERROR: Not writable")
            return 0
        }
        
        status = .Writing
        #if os(Linux)
            let written = Glibc.write(fd, buffer, len)
        #else
            let written = Darwin.write(fd, buffer, len)
        #endif
        if written > -1 {
            status = .Open
        } else {
            status = .Error
        }
        return written
    }
}
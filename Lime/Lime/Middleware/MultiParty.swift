//
//  MultiParty.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 9..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi


/*
    It is signification current parsing state
    Carry on with the parsing with each state.
*/


public enum ReadState: Int{
    case CreateBoundary = 1
    case DispositionValid
    case CreateObject
    case DispositionName
    case DispositionFilename
    case ContentType
    case ReadFile
    case ReadValue
    case CheckBoundary
    case Terminate
}


/*
    This Class need to parse Multipart/form-data
    It store file path, name, etc.
*/

public class MultiFile: File {
    //dev
    var writeStream: FileSystem.WriteStream!
    
    //public
    public var name: String!
    public var nameBuffer  = [Int8]()
    
    public var type: String! = "str"
    public var typeBuffer = [Int8]()
    
    //file
    public var fileName: String! = nil
    public var fileNameBuffer = [Int8]()
    public var path: String! = nil
    
    //body
    public var value: String! = nil
    public var valueBuffer = [Int8]()
    
    public func prepare(){
        
        self.name = removePrefixFuxfix(String(data: NSData(bytes: UnsafePointer<Void>(self.nameBuffer), length: self.nameBuffer.count), encoding: NSUTF8StringEncoding)!)
        self.type = String(data: NSData(bytes: UnsafePointer<Void>(self.typeBuffer), length: self.typeBuffer.count), encoding: NSUTF8StringEncoding)
        self.value = String(data: NSData(bytes: UnsafePointer<Void>(self.valueBuffer), length: self.valueBuffer.count), encoding: NSUTF8StringEncoding)

    }
    
    public func getPath(dirName: String) -> String{
    
        getComponent(String(data: NSData(bytes: UnsafePointer<Void>(self.fileNameBuffer), length: self.fileNameBuffer.count), encoding: NSUTF8StringEncoding)!) { name in
            self.fileName = name
            self.path = "\(dirName)/\(self.fileName)"
        }
        return path
    }

    public init(){
    }
}


/*
    This Class Real-time parse Multipart/form-data 
    This is reading and parsing by changing the state.
*/

public class MultiParty: Middleware {
    
    public var name: MiddlewareName = .Undefined
    public var fileDestName: String = __dirname
    private var limits: String!
    
    
    private var crlfCount = 0
    private var hyphenCount = 0
    private var boundary = [Int8]()
    private var cursor = 0
    private var previos: Int8 = 0
    private var current: Int8 = 0
    private var fileBufferBeginIndex = -1
    
    let CR: Int8 = 13
    let LF: Int8 = 10
    let space: Int8 = 32
    let semicolon: Int8 = 59
    let hyphen: Int8 = 45
    
    var state: ReadState = .CreateBoundary
    
    private var file: MultiFile!
    
    private var contentLength = 0
    private var totalReadLength = 0
    
    
    let dispotion = "Content-Disposition: form-data"
    var dispositionList = [Int8]()
    
    let dispotionName = "name="
    var dispositionNameList = [Int8]()
    
    
    let dispotionFileName = " filename="
    var dispositionFileNameList = [Int8]()
    
    let contentType = "Content-Type: "
    var contentTypeList = [Int8]()
    

    //options has limits, dest, filter
    
    var options: [String:String!]!

    
    public init(options : [String:String!]! = nil){
        if let opt = options{
            self.options = opt
            if let dest = opt["dest"] {
                fileDestName = dest
            }
        }
        for d in dispotion.utf8 {
            dispositionList.append(Int8(d))
        }
        for d in dispotionName.utf8 {
            dispositionNameList.append(Int8(d))
        }
        for d in dispotionFileName.utf8 {
            dispositionFileNameList.append(Int8(d))
        }
        
        for d in contentType.utf8 {
            contentTypeList.append(Int8(d))
        }

        
    }
    
    // Should be implemented in order to use as middleware.
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        
        var contentType = req.header[Content_Type]
        
        
        guard contentType?.containsString("multipart/form-data") == true else{
            return next!()
        }
        
        if req.body == nil {
            req.body = [String:String]()
        }
        if req.files == nil {
            req.files = [String:File]()
        }

        if let contentLength = req.header[Content_Length]{
            self.contentLength = Int(contentLength)!
        }
        
        
        
        // Data comes in, will be called
        //Data is that reading the parsing.
        
        func ondata(data: NSData){
            self.totalReadLength += data.length

            var fileSize = 0

            var itr = UnsafePointer<Int8>(data.bytes)
            
            for dataIndex in 0..<data.length {
                
                current = itr.memory
                itr = itr.successor()
                
                
                switch state {
                case .CreateBoundary:
                    if previos == CR && current == LF {
                        boundary.removeLast()
                        state = .DispositionValid
                    }else{
                       boundary.append(current)
                    }
                    break
                    
                case .DispositionValid:
                    
                    if cursor == dispositionList.count{
                        if current != semicolon {
                            print("Invalid DispositionValid - semi")
                        }
                        state = .CreateObject
                        cursor = 0
                    }else if dispositionList[cursor] == current {
                        cursor += 1
                    }else{
                        print("Invalid DispositionValid")
                    }
                    
                    break
                case .CreateObject:
                    if current != space {
                        print("Invalid CreateObject")
                    }
                    self.file = MultiFile()
                    state = .DispositionName
                    break
                case .DispositionName:
                
                    if current == semicolon{
                        cursor = 0
                        state = .DispositionFilename
                    } else if previos == CR && current == LF {
                        cursor = 0
                        file.nameBuffer.removeLast()
                        state = .ReadValue
                    }else if cursor == dispositionNameList.count {
                        file.nameBuffer.append(current)
                    }else if dispositionNameList[cursor] == current{
                        cursor += 1
                    }else{
                        print("Invalid DispositionName")
                    }
                    break
                case .DispositionFilename:
                    
                    if previos == CR && current == LF {
                        cursor = 0
                        file.fileNameBuffer.removeLast()
                        state = .ContentType
                    }else if cursor == dispositionNameList.count {
                        file.fileNameBuffer.append(current)
                    }else if dispositionFileNameList[cursor] == current{
                        cursor += 1
                    }else{
                        
                        print("Invalid DispositionFilename")
                    }

                    break
                case .ContentType:
                    
                    
                    if previos == CR && current == LF && crlfCount == 3 {
                        cursor = 0
                        file.writeStream = FileSystem.WriteStream(path: file.getPath(fileDestName))
                        state = .ReadFile
                    }else if current == CR || current == LF {
                        crlfCount += 1
                    }else if cursor == contentTypeList.count {
                        file.typeBuffer.append(current)
                    }else if contentTypeList[cursor] == current{
                        cursor += 1
                    }else{
                        print("Invalid ContentType")
                    }
                    break
                case .ReadFile:
                    
                    if boundary[cursor] == current{
                        cursor += 1
                    }else{
                        if cursor != 0 {
                            fileSize += cursor
                            if fileBufferBeginIndex == -1 {
                                fileSize = 0
                                writefile(NSData(bytes: boundary, length: cursor), file: file)
                            }
                            cursor = 0
                        }
                        if fileBufferBeginIndex == -1 {
                            fileBufferBeginIndex = dataIndex

                        }
                        fileSize += 1
                    }
                    if cursor == boundary.count || data.length - 1 == dataIndex {
                        if cursor == boundary.count{
                            fileSize -= 2
                            state = .CheckBoundary
                        }
                        
                        writefile(data.subdataWithRange(NSRange(location: fileBufferBeginIndex, length: fileSize)), file: file)
                        cursor = 0
                        fileSize = 0
                        crlfCount = 0
                        fileBufferBeginIndex = -1
                        
                    }

                    break
                case .ReadValue:
                    if crlfCount > 1{
                        if boundary[cursor] == current{
                            cursor += 1
                            if cursor == boundary.count {
                                cursor = 0
                                crlfCount = 0
                                state = .CheckBoundary
                                file.valueBuffer.removeLast()
                                file.valueBuffer.removeLast()
                            }
                        }else{
                            if cursor != 0 {
                                for index in 0..<cursor{
                                    file.valueBuffer.append(boundary[index])
                                }
                                cursor = 0
                            }
                        
                            file.valueBuffer.append(current)
                        }
                    }else{
                        if current == CR || current == LF {
                            crlfCount += 1
                        }else{
                             print("Invalid ReadValue")
                        }
                    }
                    break
                    
                case .CheckBoundary:
                    
                    if hyphenCount > 0 || crlfCount > 0 {
                        if hyphenCount * crlfCount > 0 {
                            print("Invalid CheckBoundary")
                        }
                        if hyphenCount > 0 {
                            state = .Terminate
                            hyphenCount = 0
                        }else if crlfCount > 0 {
                            state = .DispositionValid
                            crlfCount = 0
                        }
                        
                        
                        file.prepare()
                        
                        if file.writeStream != nil {
                            file.writeStream.close()
                            req.files[file.name] = file
                        }
                        
                        if file.value != nil {
                            req.body[file.name] = file.value

                        }
                        file = nil
                        
                        
                    }else if current == CR || current == LF {
                        crlfCount += 1
                    }else if current == hyphen {
                        hyphenCount += 1
                    }else{
                    }

                    break
                    
                case .Terminate:
                    break

                }
                previos = current
            }
        }
        
        
        
        // End of Body Data
        func onend(){
            self.totalReadLength = 0
            self.contentLength = 0
            self.cursor = 0
            self.boundary.removeAll()
            self.previos = 0
            self.current = 0
            self.hyphenCount = 0
            self.crlfCount = 0
            self.state = .CreateBoundary
            next!()
        }
        
        req.on("data", ondata)
        req.on("end", onend)
        
        
    }
    
    
    private func writefile(data: NSData, file: MultiFile){

        file.writeStream.writeData(data)
    }
    
    private func readBoundry(data: String) -> String{
        
        guard data.length() > 0 else{
            return ""
        }
    
        var index = 0
        for utfString in data.utf8 {
            if utfString == 13 {
                break
            }
            index += 1
        }
        
        return data.substring(0, length: index)
    }
}

//helper to paring data 
public func getComponent(data: String , result: (String)->()){
    let dispositionComponents = data.componentsSeparatedByString("=")
        
    result(removePrefixFuxfix(dispositionComponents[1]))

}

public func removePrefixFuxfix(src: String) ->String{
    var str = src
    if str.hasPrefix("\"") {
        str.removeAtIndex(str.startIndex)
    }
    if str.hasSuffix("\"") {
        str.removeAtIndex(str.endIndex.predecessor())
    }
    return str
}


//
//  HttpParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation


public struct HeaderInfo{
    public var header = [ String: String ]()
    public var versionMajor: String!
    public var versionMinor: String!
    public var url: String!
    public var method: String!
    public var hasbody: Bool!
    public init(){
    }

}

public class HttpParser{
    
    public var incoming: IncomingMessage!
    public var socket: Socket!
    
    public var onHeader: ((Void) -> (Void))?
    public var onHeaderComplete: ((HeaderInfo) -> Void)?
    public var onBody: ((NSData) -> Void)?
    public var onBodyComplete: ((Void) -> Void)?
    public var onIncoming: ((IncomingMessage) -> Bool)?
    
    public var date: NSDate = NSDate()
    
    //only header
    public var headerInfo: HeaderInfo! = nil
    
    //only body
    private var contentLength: Int = 0
    private var totalLength: Int = 0
    private var hasbody = false
    
    
    public init (){
    }
    
    deinit{
    }

    
    func headerParser(p:UnsafePointer<Int8> , length: Int ,onHeaderInfo: (String,Bool)->() , onBodyData: (NSData)->()) {
    
        readLine(p, length: length) { (pointer, data, readTotalSize, readlineSize) -> (Bool) in

            if data == "" {
                onHeaderInfo(data , true)
                self.totalLength = length - readTotalSize
                
                if self.totalLength == 0 {
                    return false
                }else{
                    let body = NSData(bytes: pointer+2, length: self.totalLength)
                    onBodyData(body)
                    return false
                }
            }
            
            onHeaderInfo(data , false)
            return true
        }
        
        
//        var itr = p
//        var startByte = itr
//        
//        let CR: Int8 = 13
//        let LF: Int8 = 10
//        
//        var pre: Int8 = 0
//        var crt: Int8 = 0
//        var index = 0
//        
//        var readLength = 0
//        for _ in 0..<length {
//            
//            crt = itr.memory
//            itr = itr.successor()
//            index += 1
//            readLength += 1
//            if pre == CR && crt == LF {
//                
//                let data = NSData(bytes: startByte, length: index-2)
//                if index == 2 {
//                    onHeaderInfo(String(data: data, encoding: NSASCIIStringEncoding)! , true)
//                    self.totalLength = length - readLength
//                    
//                    if self.totalLength == 0 {
//                        return
//                    }else{
//                        let body = NSData(bytes: startByte+index, length: self.totalLength)
//                        return onBodyData(body)
//                    }
//                }
//                
//                onHeaderInfo(String(data: data, encoding: NSASCIIStringEncoding)! , false)
//                
//                index = 0
//                startByte = itr
//    
//            }
//            pre = crt
//        }
    }
    
    public func execute(data: NSData, length: Int){

        if self.headerInfo == nil{            
            var headerCount = 0
            self.headerInfo = HeaderInfo()
            onHeader!()
            
            headerParser(UnsafePointer<Int8>(data.bytes), length: length, onHeaderInfo: { headerLine , isFinish in
                
                if isFinish == true {
                    self.onHeaderComplete!(self.headerInfo)
                }
                
                //first Line parse
                if headerCount == 0 {
                    let requestLineElements: [String] = headerLine.componentsSeparatedByString ( SP )
                    
                    // This is only for HTTP/1.x
                    if requestLineElements.count == 3 {
                        self.headerInfo.method = requestLineElements[0]
                        self.headerInfo.url = requestLineElements[1]
                        let httpProtocolString = requestLineElements.last!
                        let versionComponents: [String] = httpProtocolString.componentsSeparatedByString( "/" )
                        let version: [String] = versionComponents.last!.componentsSeparatedByString( "." )
                        self.headerInfo.versionMajor = version.first!
                        self.headerInfo.versionMinor = version.last!
                    }
                }else{
                    if let fieldSet: [String] = headerLine.componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                        self.headerInfo.header[fieldSet[0].trim()] = fieldSet[1].trim();
                        if let contentLength = self.headerInfo.header[Content_Length]{
                            self.contentLength = Int(contentLength)!
                        }
                    }
                }
                
                headerCount += 1
                
            } , onBodyData: { body in

                self.onBody!(body)
                
                self.headerInfo.hasbody = true
                if self.contentLength == body.length {
                    self.onBodyComplete!()
                    self.reset()
                }
            })
            
        }else{

            if self.contentLength > 0 {
                
                self.totalLength += length
                onBody!(data)
                if self.totalLength >= self.contentLength{
                    self.onBodyComplete!()
                    reset()
                }
            }
        }
    }
    
    private func reset(){
        self.totalLength = 0
        self.contentLength = 0
        self.headerInfo = nil
    }
}

public func readLine(p:UnsafePointer<Int8> , length: Int, line: (UnsafePointer<Int8>, String!, Int, Int)->(Bool)){
    var itr = p
    var startByte = itr
    
    let CR: Int8 = 13
    let LF: Int8 = 10
    
    var pre: Int8 = 0
    var crt: Int8 = 0
    var index = 0
    var lineStr: String! = nil
    var readLength = 0

    var isContinue: Bool = false
    
    for _ in 0..<length {
        
        crt = itr.memory
        itr = itr.successor()
        index += 1
        readLength += 1
        if pre == CR && crt == LF {
            
            let data = NSData(bytes: startByte, length: index-2)
            lineStr = String(data: data, encoding: NSASCIIStringEncoding)!
            
            isContinue = line(startByte, lineStr, readLength , index-2)
            
            if isContinue == false {
                return
            }
            index = 0
            startByte = itr
            
        }
        pre = crt
    }
}
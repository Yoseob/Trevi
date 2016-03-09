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
    public var onBody: ((String) -> Void)?
    public var onBodyComplete: ((Void) -> Void)?
    public var onIncoming: ((IncomingMessage) -> Bool)?
    
    public var date: NSDate = NSDate()
    
    //only header
    public var headerInfo: HeaderInfo!
    
    //only body
    private var contentLength: Int = 0
    private var totalLength: Int = 0
    private var hasbody = false
    private var endOfheader = false
    private var trace = ""
    
    
    private var firstRequestSize = 0
    
    private var headerString: String!
    
    private var bodyString: String!{
        didSet{
        }
    }
    public init (){
    }
    deinit{
    }

    private func parse(data: NSData , nread: Int, cb: ((dt: UnsafeMutablePointer<CChar> , len: Int)->())){
        let readLen = nread
        var bufSize = 4096*4
        var offset = 0
        let readBuf = UnsafeMutablePointer<CChar>.alloc(bufSize)
        
        while offset < readLen {
            
            if readLen < (offset + bufSize){
                bufSize = readLen - offset
            }
            data.getBytes(readBuf, range: NSMakeRange(offset, bufSize))
            cb(dt: readBuf, len: bufSize)
            offset += bufSize
        }
        readBuf.dealloc(bufSize)
    }
    
    

    
    //test
    func headerParser(p:UnsafePointer<Int8> , length: Int ,onHeaderInfo: (String,Bool)->() , onBodyData: (NSData)->()) {
    
        var itr = p
        
        var startByte = itr
        
        let CR: Int8 = 13
        let LF: Int8 = 10
        
        var pre: Int8 = 0
        var crt: Int8 = 0
        var index = 0
        
        var readLength = 0
        for _ in 0..<length {
            
            crt = itr.memory
            itr = itr.successor()
            index += 1
            readLength += 1
            if pre == CR && crt == LF {
                

                let data = NSData(bytes: startByte, length: index-2)
                
                
                if index == 2 {
                    onHeaderInfo(String(data: data, encoding: NSASCIIStringEncoding)! , true)
                    self.totalLength = length - readLength
                    
                    if self.totalLength == 0 {
                        return
                    }else{
                        let body = NSData(bytes: startByte, length: self.totalLength)
                        
                        return onBodyData(body)
                    }
                }
                
                onHeaderInfo(String(data: data, encoding: NSASCIIStringEncoding)! , false)
                
                index = 0
                startByte = itr
    
            }
            pre = crt

            
        
            
        }
        

        
        
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
                    }
                }
                
                headerCount += 1
                
            } , onBodyData: { body in
                
                let testString = String(data: body, encoding: NSASCIIStringEncoding)!
                self.onBody!(testString)
                
                self.headerInfo.hasbody = true
                if let contentLength = self.headerInfo.header[Content_Length]{
                    self.contentLength = Int(contentLength)!
                    if self.contentLength == body.length {
                        self.onBodyComplete!()
                        self.reset()
                    }
                }
            })
            
        }else{
            if self.contentLength > 0 {
                self.totalLength += length
                let readData = String(data : data, encoding : NSASCIIStringEncoding)
                onBody!(readData!)
                if self.totalLength >= self.contentLength{
                    print("last total length : \(self.totalLength) , \(self.contentLength)")
                    self.onBodyComplete!()
                    reset()
                }
            }
        }
    }
    
    private final func headerParserBegin (requestHeader: [String]) {
        guard headerString != nil else{
            return
        }
        
        let requestLineElements: [String] = requestHeader.first!.componentsSeparatedByString ( SP )
        
        // This is only for HTTP/1.x
        if requestLineElements.count == 3 {
            self.headerInfo.method = requestLineElements[0]
            self.headerInfo.url = requestLineElements[1]
            let httpProtocolString = requestLineElements.last!
            let versionComponents: [String] = httpProtocolString.componentsSeparatedByString( "/" )
            let version: [String] = versionComponents.last!.componentsSeparatedByString( "." )
            self.headerInfo.versionMajor = version.first!
            self.headerInfo.versionMinor = version.last!
            
            parserHeaderWithComplete(requestHeader, onbody: { body , isFinish in
                if let body = body {
                    self.onBody!(body)
                }
                if isFinish {
                    self.onBodyComplete!()
                    self.reset()
                }
            })
        }
    }

    private func parserHeaderWithComplete(headers: [String], onbody: (String! , Bool)->()){
        var fields = headers
        totalLength = 0
        for _idx in 1 ..< fields.count {
            
            if endOfheader && fields[_idx].length() > 0 && hasbody{
                
                
                if hasbody{
                    let doubleSplite: [String] = headerString.componentsSeparatedByString ( CRLF+CRLF )
                    let haederLength = doubleSplite.first!.length() + 4
                    self.totalLength += (firstRequestSize - haederLength)
                    firstRequestSize = 0
                }

                let range = Range(start: 0, end: _idx)
                fields.removeRange(range)
                
                let body = fields.joinWithSeparator(CRLF)
                
                var isFinish = false
                if totalLength >= contentLength{
                    isFinish = true
                }
                
                return onbody(body,isFinish)
            }
            
            if fields[_idx].length() == 0 && endOfheader == false{
                if let contentLength = self.headerInfo.header[Content_Length]{
                    self.contentLength = Int(contentLength)!
                    hasbody = true
                    self.headerInfo.hasbody = hasbody
                }
                endOfheader = true
                self.onHeaderComplete!(self.headerInfo)
                self.headerInfo = nil
            }
            if self.headerInfo != nil {
                if let fieldSet: [String] = fields[_idx].componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                    self.headerInfo.header[fieldSet[0].trim()] = fieldSet[1].trim();
                }
            }
        }
    }
    
    private func reset(){
        self.headerString = nil
        self.totalLength = 0
        self.headerInfo = nil
    }
}
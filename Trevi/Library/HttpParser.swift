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
    public var onBody: ((AnyObject) -> Void)?
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
    
    
    public func execute(data: NSData, length: Int){
        self.firstRequestSize = length
    
        if self.headerString == nil{
            let readData = String(data : data, encoding : NSASCIIStringEncoding)
            self.onHeader!()
            self.headerInfo = HeaderInfo()
            self.headerString = readData 
            self.headerParserBegin((readData?.componentsSeparatedByString(CRLF))!)
        }else{
            if self.contentLength > 0 {
                self.totalLength += length
                let readData = String(data : data, encoding : NSASCIIStringEncoding)
                self.onBody!(readData!)
                if self.totalLength >= self.contentLength{
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
            parseHeader( requestHeader )

            if  totalLength > 1 {
                onBody!(trace)
                trace = ""
            }
            
            if (contentLength == 0) || (self.totalLength == contentLength) {
                self.onBodyComplete!()
                reset()
            }
        }
    }
    
    private func reset(){
        self.headerString = nil
        self.totalLength = 0
        self.headerInfo = nil
    }
    
    private final func parseHeader ( fields: [String] ) {
        for _idx in 1 ..< fields.count {

            if endOfheader && fields[_idx].length() > 0 && hasbody{
                self.trace += fields[_idx]
                self.trace += CRLF
            }

            if fields[_idx].length() == 0 && endOfheader == false{
                if let contentLength = self.headerInfo.header[Content_Length]{
                    self.contentLength = Int(contentLength)!
                    hasbody = true
                    self.headerInfo.hasbody = hasbody
                }
                endOfheader = true
                self.onHeaderComplete!(self.headerInfo)
            }
            
            if let fieldSet: [String] = fields[_idx].componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                self.headerInfo.header[fieldSet[0].trim()] = fieldSet[1].trim();
            }
        }
        
        if hasbody{
            let doubleSplite: [String] = headerString.componentsSeparatedByString ( CRLF+CRLF )
            let haederLength = doubleSplite.first!.length() + 4
            self.totalLength += firstRequestSize - haederLength
        }
    }
}
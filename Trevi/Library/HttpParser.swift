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
    
    private var headerString: String!{
        didSet{
            headerParserBegin()
        }
    }
    private var bodyString: String!{
        didSet{
        }
    }
    public init (){
    }
    deinit{
    }
    
    public func execute(data: UnsafeMutablePointer<CChar>! = nil, length: Int){

        let readData: String! = blockToString(data, length: length)
        if self.headerString == nil{
            self.onHeader!()
            self.headerInfo = HeaderInfo()
            self.headerString = readData
        }else{
            if contentLength > 0 {
                totalLength += length
                onBody!(readData)
                if totalLength >= contentLength{
                    onBodyComplete!()
                }
            }
        }
    }
    
    private final func headerParserBegin () {
        let requestHeader: [String] = headerString.componentsSeparatedByString ( CRLF )
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
            
            
            if trace.length() > 1 {
                onBody!(trace)
                trace = ""
            }
            
            if trace.length() == 0 && contentLength == 0 {
                self.onBodyComplete!()
            }
            
        }
    }
    
    private final func parseHeader ( fields: [String] ) {
        for _idx in 1 ..< fields.count {

            if endOfheader && fields[_idx].length() > 0 && hasbody{
                self.trace += fields[_idx]
            }

            if fields[_idx].length() == 0 && endOfheader == false{
                if let contentLength = self.headerInfo.header[Content_Length]{
                    self.contentLength = Int(contentLength)!
                    hasbody = true
                }
                endOfheader = true
                self.onHeaderComplete!(self.headerInfo)
            }
            
            if let fieldSet: [String] = fields[_idx].componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                self.headerInfo.header[fieldSet[0].trim()] = fieldSet[1].trim();
            }
        }
    }
    
}
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
    public var onBody: ((Void) -> Void)?
    public var onBodyComplete: ((Void) -> Void)?
    public var onIncoming: ((IncomingMessage) -> Void)?
    
    
    //only header
    public var headerInfo: HeaderInfo!
    
    //only body
    private var contentLength: Int = 0
    private var totalLength: Int = 0
    
    private var trace = ""
    
    private var headerString: String!{
        didSet{
            parse()
        }
    }
    
    private var endOfheader = false
    
    public func execute(buf: uv_buf_const_ptr = nil, length: Int){
    
        let readData = blockToUTF8String(buf.memory.base)
        
        if self.headerString == nil{
            self.headerInfo = HeaderInfo()
            self.headerString = readData
            self.onHeader!()
        }
    }
    
    private final func parse () {
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
        }
   
    }
    private final func parseHeader ( fields: [String] ) {
        for _idx in 1 ..< fields.count {
            
            if fields[_idx].length() == 0 && endOfheader == false{
                self.onHeaderComplete!(self.headerInfo)

                endOfheader = true
            }
            if(endOfheader){
                
            }
            
            if let fieldSet: [String] = fields[_idx].componentsSeparatedByString ( ":" ) where fieldSet.count > 1 {
                self.headerInfo.header[fieldSet[0].trim()] = fieldSet[1].trim();
            }else{
                trace += fields[_idx]
            }
        }
    }
    
}
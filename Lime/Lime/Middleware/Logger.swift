//
//  Logger.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2016. 1. 5..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

/**
 A Middleware for logging client connection.
 */
public class Logger: Middleware {
    
    public var name: MiddlewareName
    
    private typealias Function = (IncomingMessage, ServerResponse) -> String
    private let _format: String
    private var _funcTbl = [String : Function]()
    
    public init (format: String) {
        name = .Logger
        
        switch (format) {
        case "default":
            _format = ":remote-addr - - [ :date ] \":method :url HTTP/:http-version\" :status :res[content-length] \":referrer\" \":user-agent\""
            
        case "short":
            _format = ":remote-addr - :method :url HTTP/:http-version :status :res[content-length] - :response-time ms"
            
        case "tiny":
            _format = ":method :url :status :res[content-length] - :response-time ms"
            
        default:
            _format = format
        }
        
        _funcTbl[ "http-version" ] = http_version
        _funcTbl[ "response-time" ] = response_time
        _funcTbl[ "remote-addr" ] = remote_addr
        _funcTbl[ "date" ] = date
        _funcTbl[ "method" ] = method
        _funcTbl[ "url" ] = url
        _funcTbl[ "referrer" ] = referrer
        _funcTbl[ "user-agent" ] = user_agent
        _funcTbl[ "status" ] = status
    }
    
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) -> () {
        res.onFinished = logRequest
        next!()
    }
    
    private func logRequest(response res: ServerResponse) {
        let log = compile( res.req, res: res )
        print( log )
    }
    
    private func compile(req: IncomingMessage, res: ServerResponse) -> String {
        var isCompiled = false
        var compiled = String(_format)
        
        for tokens in searchWithRegularExpression(_format, pattern: ":res\\[(.*?)\\]", options: [ .CaseInsensitive ]) {
            for type in HttpHeaderType.allValues where type.rawValue.lowercaseString == tokens["$1"]!.text.lowercaseString {
                guard let logPiece : String = res.header[ type.rawValue ] else {
                    compiled = compiled.stringByReplacingOccurrencesOfString( ":res[\(tokens["$1"]!.text)]", withString: "" )
                    continue
                }
                
                compiled = compiled.stringByReplacingOccurrencesOfString( ":res[\(tokens["$1"]!.text)]", withString: logPiece )
                isCompiled = true
            }
        }
        
        for tokens in searchWithRegularExpression(_format, pattern: ":([A-z0-9\\-]*)", options: [ .CaseInsensitive ]) {
            // get function by token
            guard let tokenFunc = _funcTbl[tokens["$1"]!.text.lowercaseString] else {
                compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokens["$1"]!.text)", withString: "" )
                continue
            }
            
            compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokens["$1"]!.text)", withString: tokenFunc(req, res) )
            isCompiled = true
        }
        
        return isCompiled ? compiled : ""
    }
    
    private func http_version ( req: IncomingMessage, res: ServerResponse ) -> String {
        return req.version
    }
    
    private func response_time ( req: IncomingMessage, res: ServerResponse ) -> String {
        let elapsedTime = Double( res.startTime.timeIntervalSinceDate( req.startTime ) )
        return "\(elapsedTime * 1000)"
    }
    
    private func remote_addr ( req: IncomingMessage, res: ServerResponse ) -> String {
        guard let addr = getEndpointFromSocketAddress(Tcp.getPeerName(uv_tcp_ptr(req.socket.handle))) else {
            return ""
        }
        return addr.host
    }
    
    private func date ( req: IncomingMessage, res: ServerResponse ) -> String {
        return getCurrentDatetime()
    }
    
    private func method ( req: IncomingMessage, res: ServerResponse ) -> String {
        return req.method.rawValue
    }
    
    private func url ( req: IncomingMessage, res: ServerResponse ) -> String {
        return req.url
    }
    
    private func referrer ( req: IncomingMessage, res: ServerResponse ) -> String {
        if let referer = req.header["referer"] {
            return referer
        } else if let referrer = req.header["referrer"] {
            return referrer
        } else {
            return ""
        }
    }
    
    private func user_agent ( req: IncomingMessage, res: ServerResponse ) -> String {
        if let agent = req.header["user-agent"] {
            return agent
        } else {
            return ""
        }
    }
    
    private func status ( req: IncomingMessage, res: ServerResponse ) -> String {
        return "\(res.statusCode)"
    }
}
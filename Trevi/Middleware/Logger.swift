//
//  Logger.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2016. 1. 5..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation

enum LoggerToken: String {
    case Response       = "res"
    case HttpVersion    = "http-version"
    case ResponseTime   = "response-time"
    case RemoteAddr     = "remote-addr"
    case Date           = "date"
    case Method         = "method"
    case Url            = "url"
    case Referrer       = "referrer"
    case UserAgent      = "user-agent"
    case Status         = "status"
}


/**
 A Middleware for logging client connection.
 */
public class Logger: Middleware {
    
    private typealias Function =  ( Request, Response ) -> String
    
    private let format: String
    private var funcTbl = [String : Function]()
    
    public var name: MiddlewareName;
    
    public init ( format: String ) {
        name = .Logger
        
        switch (format) {
            
        case "default":
            self.format = ":remote-addr - - [ :date ] \":method :url HTTP/:http-version\" :status :res[content-length] \":referrer\" \":user-agent\""
            
        case "short":
            self.format = ":remote-addr - :method :url HTTP/:http-version :status :res[content-length] - :response-time ms"
            
        case "tiny":
            self.format = ":method :url :status :res[content-length] - :response-time ms"
            
        default:
            self.format = format
            
        }
        
        self.funcTbl[ "http-version" ] = http_version
        self.funcTbl[ "response-time" ] = response_time
        self.funcTbl[ "remote-addr" ] = remote_addr
        self.funcTbl[ "date" ] = date
        self.funcTbl[ "method" ] = method
        self.funcTbl[ "url" ] = url
        self.funcTbl[ "referrer" ] = referrer
        self.funcTbl[ "user-agent" ] = user_agent
        self.funcTbl[ "status" ] = status
    }
    
    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        let req: Request  = params.req
        let res: Response = params.res
        
        res.onFinished = { _res in
            self.logRequest( request: req, response: _res )
        }
        
        return false;
    }
    
    private func logRequest( request req: Request, response res: Response ) {
        
        let log = compile( req, res: res )
        print( log )
    }
    
    private func compile( req: Request, res: Response ) -> String {
        
        var isCompiled = false;
        var compiled = String( self.format )
        
        if let regex: NSRegularExpression = try? NSRegularExpression ( pattern: ":res\\[(.*?)\\]", options: [ .CaseInsensitive ] ) {
            
            for match in regex.matchesInString ( self.format, options: [], range: NSMakeRange( 0, self.format.length() ) ) {
                let tokenRange = match.rangeAtIndex( 1 )
                let tokenStr   = self.format.substring ( tokenRange.location, length: tokenRange.length )
                
                for type in HttpHeaderType.allValues {
                    if tokenStr.lowercaseString == type.rawValue.lowercaseString {
                        
                        guard let logPiece : String = res.header[ type.rawValue ] else {
                            compiled = compiled.stringByReplacingOccurrencesOfString( ":res[\(tokenStr)]", withString: "" )
                            continue;
                        }
                        
                        compiled = compiled.stringByReplacingOccurrencesOfString( ":res[\(tokenStr)]", withString: logPiece )
                        isCompiled = true
                    }
                }
            }
        }
        
        guard let regex: NSRegularExpression = try? NSRegularExpression ( pattern: ":([A-z0-9\\-]*)", options: [ .CaseInsensitive ] ) else {
            return isCompiled ? compiled : ""
        }
        
        // Find tokens in format
        for match in regex.matchesInString ( self.format, options: [], range: NSMakeRange( 0, self.format.length() ) ) {
            let tokenRange = match.rangeAtIndex( 1 )
            let tokenStr   = self.format.substring ( tokenRange.location, length: tokenRange.length )
            
            guard let token = LoggerToken ( rawValue: tokenStr ) else {
                compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokenStr)", withString: "" )
                continue;
            }
            
            guard let tokenFunc = funcTbl[ token.rawValue ] else {
                compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokenStr)", withString: "" )
                continue;
            }
            
            compiled = compiled.stringByReplacingOccurrencesOfString( ":\(tokenStr)", withString: tokenFunc( req, res ) )
            isCompiled = true
        }
        
        return isCompiled ? compiled : ""
    }
    
    private func http_version ( req: Request, res: Response ) -> String {
        return req.version
    }
    
    private func response_time ( req: Request, res: Response ) -> String {
        let elapsedTime = Double( res.startTime.timeIntervalSinceDate( req.startTime ) )
        return "\(elapsedTime * 1000)"
    }
    
    // Not suuport yet
    private func remote_addr ( req: Request, res: Response ) -> String {
        return res.socket!.ip
    }
    
    private func date ( req: Request, res: Response ) -> String {
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .LongStyle
        return formatter.stringFromDate(date)
    }
    
    private func method ( req: Request, res: Response ) -> String {
        return req.method.rawValue
    }
    
    private func url ( req: Request, res: Response ) -> String {
        return req.path
    }
    
    private func referrer ( req: Request, res: Response ) -> String {
        if let referer = req.header[ "referer" ] {
            return referer
        } else if let referrer = req.header[ "referrer" ] {
            return referrer
        } else {
            return ""
        }
    }
    
    private func user_agent ( req: Request, res: Response ) -> String {
        if let agent = req.header[ "user-agent" ] {
            return agent
        } else {
            return ""
        }
    }
    
    private func status ( req: Request, res: Response ) -> String {
        return "\(res.status)"
    }
}

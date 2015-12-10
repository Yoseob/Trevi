//
//  Response.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Response {

    public var header = [ String: String ] ()
    public var body = [ String: String ]! ()

    public var bodyString: String? {
        didSet {
            if let _ = header[Content_Type] {
                header[Content_Type] = "text/plain"
            }
        }
    }
    public var statusString: String {
        return internalStatus.statusString ()
    }
    public var statusCode: Int {
        return internalStatus.rawValue
    }
    public var status: Int {
        set {
            internalStatus = StatusCode ( rawValue: newValue )!
        }
        get {
            return statusCode
        }
    }
    private var internalStatus: StatusCode = .OK

    private var socket:   SwiftSocket?
    public var  renderer: Renderer?

    private var bodyData: NSData? {

        var resultBodyString: String!
        if let bodyString = bodyString {
            resultBodyString = bodyString
        } else if let b = body {
            resultBodyString = dictionaryToString ( b );
        }

        return resultBodyString.dataUsingEncoding ( NSUTF8StringEncoding )!
    }

    public init () {

    }

    public init ( socket: SwiftSocket ) {
        self.socket = socket   // if render , send , template func is called call self.socket.send(AnyOnject)
    }

    public func send ( data: Any ) {
        //need control flow that can divide any type
        bodyString = String ( data )
        implSend ()
    }

    public func send () {
        implSend ()
    }

    public func render ( obj: AnyObject... ) {
        let filename = obj[0] as! String
        let args: [String:String]

        if obj.count > 1 {
            args = obj[1] as! [String:String]
        } else {
            args = [:]
        }

        if let data = renderer?.render ( filename, args: args ) {
            bodyString = data;
            implSend ()
        } else {
            implSend ()
        }
    }

    public func template () {
        implSend ()
    }

    public func redirect ( url u: String ) {
        self.status = 302
        self.header[Location] = u
    }

    private func implSend () {
        let headerData       = prepareHeader ()
        let sendData: NSData = makeResponse ( headerData, body: self.bodyData! )
        socket?.sendData ( sendData )
    }


    private func makeResponse ( header: NSData, body: NSData ) -> ( NSData ) {
        let result = NSMutableData ( data: header )
        result.appendData ( body )
        return result;
    }

    private func prepareHeader () -> NSData {
        header[Content_Length] = "\(bodyData!.length)" // replace bodyString length
        header[Content_Type] = "text/html;charset=utf-8"
        var headerString = "\(HttpProtocol) \(statusCode) \(statusString)" + NewLine
        headerString += dictionaryToString ( header )
        return headerString.dataUsingEncoding ( NSUTF8StringEncoding )!

    }

    private func prepareBody () -> NSData {
        var resultBodyString: String!
        if let bodyString = bodyString where bodyString.length () > 1 {
            resultBodyString = bodyString
        } else {
            resultBodyString = dictionaryToString ( body );
        }

        return resultBodyString.dataUsingEncoding ( NSUTF8StringEncoding )!
    }

    private func dictionaryToString ( dic: NSDictionary ) -> String! {
        var resultString = ""
        for (key, value) in dic {
            if value.lengthOfBytesUsingEncoding ( NSUTF8StringEncoding ) == 0 {
                resultString += "\(key)\r\n"
            } else {
                resultString += "\(key):\(value)\r\n"
            }
        }
        resultString += NewLine
        return resultString;
    }
}

public var NewLine                     = "\r\n"
public let HttpProtocol                = "HTTP/1.1"
public var Access_Control_Allow_Origin = "Access-Control-Allow-Origin"
public var Accept_Patch                = "Accept-Patch"
public var Accept_Ranges               = "Accept-Ranges"
public var Age                         = "Age"
public var Allow                       = "Allow"
public var Cache_Control               = "Cache-Control"
public var Connection                  = "Connection"
public var Content_Disposition         = "Content-Disposition"
public var Content_Encoding            = "Content-Encoding"
public var Content_Length              = "Content_Length"
public var Content_Language            = "Content-Language"
public var Content_Location            = "Content-Location"
public var Content_MD5                 = "Content-MD5"
public var Content_Range               = "Content-Range"
public var Content_Type                = "Content-Type"
public var Date                        = "Date"
public var Expires                     = "Expires"
public var Last_Modified               = "Last-Modified"
public var Link                        = "Link"
public var Location                    = "Location"
public var ETag                        = "ETag"
public var Refresh                     = "Refresh"
public var Strict_Transport_Security   = "Strict-Transport-Security"
public var Transfer_Encoding           = "Transfer-Encoding"
public var Upgrade                     = "Upgrade"

public enum StatusCode: Int {
    func statusString () -> String! {
        switch self {
        case .Continue: return "Continue"
        case .SwitchingProtocols: return "Switching Protocols"

        case .OK: return "OK"
        case .Created: return "Created"
        case .Accepted: return "Accepted"
        case .NonAuthoritativeInformation: return "Non-Authoritative Information"
        case .NoContent: return "No Content"
        case .ResetContent: return "Reset Content"

        case .MultipleChoices: return "Multiple Choices"
        case .MovedPermanently: return "Moved Permentantly"
        case .Found: return "Found"
        case .SeeOther: return "See Other"
        case .UseProxy: return "Use Proxy"

        case .BadRequest: return "Bad Request"
        case .Unauthorized: return "Unauthorized"
        case .Forbidden: return "Forbidden"
        case .NotFound: return "Not Found"

        case .InternalServerError: return "Internal Server Error"
        case .BadGateway: return "Bad Gateway"
        case .ServiceUnavailable: return "Service Unavailable"
        default:
            return nil

        }
    }

    case Continue           = 100
    case SwitchingProtocols = 101

    case OK                          = 200
    case Created                     = 201
    case Accepted                    = 202
    case NonAuthoritativeInformation = 203
    case NoContent                   = 204
    case ResetContent                = 205

    case MultipleChoices  = 300
    case MovedPermanently = 301
    case Found            = 302
    case SeeOther         = 303
    case NotModified      = 304
    case UseProxy         = 305

    case BadRequest       = 400
    case Unauthorized     = 401
    case Forbidden        = 403
    case NotFound         = 404
    case MethodNotAllowed = 405
    case NotAcceptable    = 406
    case RequestTimeout   = 408


    case InternalServerError = 500
    case BadGateway          = 502
    case ServiceUnavailable  = 503
}

//
//  HttpProtocol.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 14..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public let CRLF = "\r\n"
public let SP = " "
public let HT = "\t"
public let unreserved = "\\w\\-\\.\\_\\~"
public let gen_delims = "\\:\\/\\?\\#\\[\\]\\@"
public let sub_delims = "\\!\\$\\&\\'\\(\\)\\*\\+\\,\\;\\="

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
public var Content_Length              = "Content-Length"
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
public var Server                      = "Server"

public enum HttpHeaderType: String {
    case Access_Control_Allow_Origin = "Access-Control-Allow-Origin"
    case Accept_Patch                = "Accept-Patch"
    case Accept_Ranges               = "Accept-Ranges"
    case Age                         = "Age"
    case Allow                       = "Allow"
    case Cache_Control               = "Cache-Control"
    case Connection                  = "Connection"
    case Content_Disposition         = "Content-Disposition"
    case Content_Encoding            = "Content-Encoding"
    case Content_Length              = "Content-Length"
    case Content_Language            = "Content-Language"
    case Content_Location            = "Content-Location"
    case Content_MD5                 = "Content-MD5"
    case Content_Range               = "Content-Range"
    case Content_Type                = "Content-Type"
    case Date                        = "Date"
    case Expires                     = "Expires"
    case Last_Modified               = "Last-Modified"
    case Link                        = "Link"
    case Location                    = "Location"
    case ETag                        = "ETag"
    case Refresh                     = "Refresh"
    case Strict_Transport_Security   = "Strict-Transport-Security"
    case Transfer_Encoding           = "Transfer-Encoding"
    case Upgrade                     = "Upgrade"
    case Server                      = "Server"
    
    public static let allValues = [ Access_Control_Allow_Origin,
                            Accept_Patch,
                            Accept_Ranges,
                            Age,
                            Allow,
                            Cache_Control,
                            Connection,
                            Content_Disposition,
                            Content_Encoding,
                            Content_Length,
                            Content_Language,
                            Content_Location,
                            Content_MD5,
                            Content_Range,
                            Content_Type,
                            Date,
                            Expires,
                            Last_Modified,
                            Link,
                            Location,
                            ETag,
                            Refresh, 
                            Strict_Transport_Security, 
                            Transfer_Encoding, 
                            Upgrade, 
                            Server ]
}

public enum HTTPMethodType: String {
    case GET       = "GET"
    case POST      = "POST"
    case PUT       = "PUT"
    case HEAD      = "HEAD"
    case DELETE    = "DELETE"
    case UNDEFINED = "UNDEFINED"
    case OPTIONS   = "OPTIONS"
}


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


/*
    Content-type and mime-type

*/
public class Mime {
    
    class func type(key: String) -> String {
        
        var mType = [
            
            "xfu":"application/x-www-form-urlencoded",
            "fdt":"multipart/form-data",
            "css":"text/css",
            "txt":"text/plain",
            "json":"application/json",
            "jpeg":"image/jpeg",
            "jpg":"image/jpeg",
            "png":"image/png",
            "html":"text/html",
            
            
            "mix":"multipart/mixed",
            "dig":"multipart/digest",
            "aln":"multipart/alternative",
            
            "aif":"audio/x-aiff",
            "aifc":"audio/x-aiff",
            "aiff":"audio/x-aiff",
            "asf":"video/x-ms-asf",
            "asr":"video/x-ms-asf",
            "asx":"video/x-ms-asf",
            "au":"audio/basic",
            "avi":"video/x-msvideo",
            "axs":"application/olescript",
            "bas":"text/plain",
            "bcpio":"application/x-bcpio",
            "bin":"application/octet-stream",
            "bmp":"image/bmp",
            "c":"text/plain",
            "cat":"application/vnd.ms-pkiseccat",
            "cdf":"application/x-netcdf",
            "cer":"application/x-x509-ca-cert",
            "class":"application/octet-stream",
            "clp":"application/x-msclip",
            "cmx":"image/x-cmx",
            "cod":"image/cis-cod",
            "cpio application/x-cpio":"undefined",
            "crd":"application/x-mscardfile",
            "crl":"application/pkix-crl",
            "crt":"application/x-x509-ca-cert",
            "csh":"application/x-csh",
            "dcr":"application/x-director",
            "der":"application/x-x509-ca-cert",
            "dir":"application/x-director",
            "dll":"application/x-msdownload",
            "dms":"application/octet-stream",
            "doc":"application/msword",
            "dot":"application/msword",
            "dvi":"application/x-dvi",
            "dxr":"application/x-director",
            "eps":"application/postscript",
            "etx":"text/x-setext",
            "evy":"application/envoy",
            "exe":"application/octet-stream",
            "fif":"application/fractals",
            "flr":"x-world/x-vrml",
            "gif":"image/gif",
            "gtar":"application/x-gtar",
            "gz":"application/x-gzip",
            "hdf":"application/x-hdf",
            "hlp":"application/winhlp",
            "hqx":"application/mac-binhex40",
            "hta":"application/hta",
            "htc":"text/x-component",
            "htt":"text/webviewhtml",
            "ico":"image/x-icon",
            "ief":"image/ief",
            "iii":"application/x-iphone",
            "ins":"application/x-internet-signup",
            "isp":"application/x-internet-signup",
            "jfif":"image/pipeg",
            "mny":"application/x-msmoney",
            "mht":"message/rfc822",
            "lsf":"video/x-la-asf",
            "mhtml":"message/rfc822",
            "mid":"audio/mid",
            "mov":"video/quicktime",
            "m3u":"audio/x-mpegurl",
            "movie":"video/x-sgi-movie",
            "mp2":"video/mpeg",
            "mp3":"audio/mpeg",
            "mpa":"video/mpeg",
            "mpe":"video/mpeg",
            "mpeg":"video/mpeg",
            "mpv2":"video/mpeg",
            "mpg":"video/mpeg",
            "mpp":"application/vnd.ms-project",
            "ms":"application/x-troff-ms",
            "msg":"application/vnd.ms-outlook",
            "mvb":"application/x-msmediaview",
            "nc":"application/x-netcdf",
            "nws":"message/rfc822",
            "acx":"application/internet-property-stream",
            "ai":"application/postscript",
            "js":"application/x-javascript",
            "latex":"application/x-latex",
            "lha":"application/octet-stream",
            "lzh":"application/octet-stream",
            "m13":"application/x-msmediaview",
            "m14":"application/x-msmediaview",
            "man":"application/x-troff-man",
            "mdb":"application/x-msaccess",
            "me":"application/x-troff-me",
            "pbm":"image/x-portable-bitmap",
            "pgm":"image/x-portable-graymap",
            "pnm":"image/x-portable-anymap",
            "ppm":"image/x-portable-pixmap",
            "qt":"video/quicktime",
            "ra":"audio/x-pn-realaudio",
            "ram":"audio/x-pn-realaudio",
            "ras":"image/x-cmu-raster",
            "rgb":"image/x-rgb",
            "rmi":"audio/mid",
            "rtx":"text/richtext",
            "sct":"text/scriptlet",
            "snd":"audio/basic",
            
            "z":"application/x-compress",
            "zip":"application/zip",
            "oda":"application/oda",
            "p10":"application/pkcs10",
            "p12":"application/x-pkcs12",
            "p7b":"application/x-pkcs7-certificates",
            "p7c":"application/x-pkcs7-mime",
            "p7m":"application/x-pkcs7-mime",
            "p7r":"application/x-pkcs7-certreqresp",
            "p7s":"application/x-pkcs7-signature",
            "pdf":"application/pdf",
            "pfx":"application/x-pkcs12",
            "pko":"application/ynd.ms-pkipko",
            "pma":"application/x-perfmon",
            "pmc":"application/x-perfmon",
            "pml":"application/x-perfmon",
            "pmr":"application/x-perfmon",
            "pmw":"application/x-perfmon",
            "pot":"application/vnd.ms-powerpoint",
            "pps":"application/vnd.ms-powerpoint",
            "ppt":"application/vnd.ms-powerpoint",
            "prf":"application/pics-rules",
            "ps":"application/postscript",
            "pub":"application/x-mspublisher",
            "roff":"application/x-troff",
            "rtf":"application/rtf",
            "scd":"application/x-msschedule",
            "setpay":"application/set-payment-initiation",
            "setreg":"application/set-registration-initiation",
            "sh":"application/x-sh",
            "shar":"application/x-shar",
            "sit":"application/x-stuffit",
            "spc":"application/x-pkcs7-certificates",
            "spl":"application/futuresplash",
            "src":"application/x-wais-source",
            "sst":"application/vnd.ms-pkicertstore",
            "stl":"application/vnd.ms-pkistl",
            "sv4cpio":"application/x-sv4cpio",
            "sv4crc":"application/x-sv4crc",
            "svg":"image/svg+xml",
            "swf":"application/x-shockwave-flash",
            "t":"application/x-troff",
            "tar":"application/x-tar",
            "tcl":"application/x-tcl",
            "tex":"application/x-tex",
            "texi":"application/x-texinfo",
            "texinfo":"application/x-texinfo",
            "tgz":"application/x-compressed",
            "wcm":"application/vnd.ms-works",
            "wdb":"application/vnd.ms-works",
            "wks":"application/vnd.ms-works",
            "wmf":"application/x-msmetafile",
            "wps":"application/vnd.ms-works",
            "wri":"application/x-mswrite",
            "xla":"application/vnd.ms-excel",
            "xlc":"application/vnd.ms-excel",
            "xlm":"application/vnd.ms-excel",
            "xls":"application/vnd.ms-excel",
            "xlt":"application/vnd.ms-excel",
            "xlw":"application/vnd.ms-excel",

            
            "tif":"image/tiff",
            "tiff":"image/tiff",
            "tr":"application/x-troff",
            "trm":"application/x-msterminal",
            "tsv":"text/tab-separated-values",
            "uls":"text/iuls",
            "ustar":"application/x-ustar",
            "vcf":"text/x-vcard",
            "vrml":"x-world/x-vrml",
            "wav":"audio/x-wav",
            "wrl":"x-world/x-vrml",
            "wrz":"x-world/x-vrml",
            "xaf":"x-world/x-vrml",
            "xbm":"image/x-xbitmap",
            "xof":"x-world/x-vrml",
            "xpm":"image/x-xpixmap",
            "xwd":"image/x-xwindowdump",

        ]
        
        if let t = mType[key] {
            return t
        }
        
        return ""
    
    }
    
}


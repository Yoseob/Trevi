//
//  Json.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 9..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public enum JSON {
    case Array( [JSON] )
    case Dictionary( [Swift.String:JSON] )
    case String( Swift.String )
    case Number( Float )
    case Null
}

extension JSON {

    public var string: Swift.String? {
        switch self {
        case .String(let s):
            return s
        default:
            return nil
        }
    }

    public var int: Int? {
        switch self {
        case .Number(let d):
            return Int ( d )
        default:
            return nil
        }
    }

    public var float: Float? {
        switch self {
        case .Number(let d):
            return d
        default:
            return nil
        }
    }

    public var bool: Bool? {
        switch self {
        case .Number(let d):
            return (d != 0)
        default:
            return nil
        }
    }

    public var isNull: Bool {
        switch self {
        case Null:
            return true
        default:
            return false
        }
    }

    public func wrap ( json: AnyObject ) -> JSON {
        if let str = json as? Swift.String {
            return .String ( str )
        }
        if let num = json as? NSNumber {
            return .Number ( num.floatValue )
        }
        if let dictionary = json as? [Swift.String:AnyObject] {

            return .Dictionary ( internalConvertDictionary ( dictionary ) )
        }
        if let array = json as? [AnyObject] {
            return .Array ( internalConvertArray ( array ) )
        }
        assert ( json is NSNull, "Unsupported Type" )
        return .Null
    }

    private func internalConvertDictionary ( dic: [Swift.String:AnyObject] ) -> [Swift.String:JSON]! {
//        var newDictionary = [:]
//        for (k,v) in dic{
//            switch v{
//            case let arr as [AnyObject]:
//                var  newarr = internalConvertArray(arr)
//
//                print(arr)
//            case let dic as [Swift.String: AnyObject]:
//                internalConvertDictionary(dic)
//            default:
//                wrap(v)
//                break
//    
//            }
//        }

        return nil;
    }

    private func internalConvertArray ( arr: [AnyObject] ) -> [JSON]! {
        return nil
    }
}

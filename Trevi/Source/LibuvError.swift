//
//  LibuvError.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 3. 10..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv
import Foundation

public class LibuvError : ErrorType {
    
    public static func printState( location : String, error : Int32 ) {
        print("Error on : \(location), name : \(uvErrorName(error)), message : \(uvErrorMessage(error))")
    }
}

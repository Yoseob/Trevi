//
//  Favicon.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation

public class Favicon: Middleware {

    public var name: MiddlewareName;

    public init () {
        name = .Favicon
    }

    public func operateCommand ( params: MiddlewareParams ) -> Bool {
        return true
    }
}
//
//  RoutAble.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//


/*
    RoutAble is interface to make module like need to start server and matched for path   
*/

import Foundation
import Trevi

public class Routable{
    internal var _router: Router!
    
    public func use(path: String = "/", _ middleware: Require){
        let r = middleware.export()
        _router.use(path, md: r)
    }
    
    //just function
    public func use(fn: HttpCallback){
        _router.use(fn)
    }
}
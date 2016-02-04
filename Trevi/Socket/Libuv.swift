//
//  Libuv.swift
//  Trevi
//
//  Created by JangTaehwan on 2016. 2. 4..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Libuv

public class Libuv {
    
    var async : uv_async_t = uv_async_t()
    var loop : uv_loop_t = uv_loop_t()
    
    public init(){
        
        // Libuv Test code
        uv_loop_init(&self.loop)
        
    }
}

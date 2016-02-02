//
//  TreviResponse.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation

public class TreviResponse : Response{
    
    public override init() {
        super.init()
    }
    
    public override init(socket: ClientSocket) {
        super.init(socket: socket)
    }
    
}
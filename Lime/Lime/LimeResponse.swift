//
//  LimeResponse.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 3..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
public class LimeResponse : Response{
    public override init() {
        super.init()
    }
    public override init ( socket: ClientSocket ) {
        super.init(socket:socket)
    }

}
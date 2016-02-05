//
//  LimeRequest.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
public class LimeRequest: Request{
    public override init () {
        super.init()
    }
    
    public override init ( _ headerStr: String ) {
        super.init(headerStr)
    }

    
}
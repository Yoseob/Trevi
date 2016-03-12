//
//  Require.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 23..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


/*
    User-defined certainly should be implemented in order to use a router.
*/
public protocol Require{
    func export() -> Router
}

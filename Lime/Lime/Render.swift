//
//  Render.swift
//  Trevi
//
//  Created by SeungHyunLee on 3/9/16.
//  Copyright © 2016 LeeYoseob. All rights reserved.
//

import Foundation

public protocol Render {
    func render(path: String, writer: ((String) -> Void))
    func render(path: String, args: [String:String], writer: ((String) -> Void))
}
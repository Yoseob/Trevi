//
//  Render.swift
//  Trevi
//
//  Created by SeungHyunLee on 3/9/16.
//  Copyright © 2016 LeeYoseob. All rights reserved.
//

import Foundation

public protocol Render {
    func render(filename: String) -> String
    func render(filename: String, args: [String:String]) -> String
}
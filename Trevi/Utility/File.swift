//
//  File.swift
//  Trevi
//
//  Created by SeungHyun Lee on 2015. 12. 5..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


/*
    This Protocol use File Type Class Of Super
    When need path, name, value, type of File object, impliment this Protocol
    Now It use file descripter Multipart/form-data 
*/

public protocol File{
    
    var name: String! {get set}
    var value: String! {get set}
    
    var type: String! {get set}
    var path: String! {get set}
}
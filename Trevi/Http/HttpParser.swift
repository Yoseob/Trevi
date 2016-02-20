//
//  HttpParser.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 2. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation


public class HttpParser{
    
    public var incoming: IncomingMessage!
    public var socket: AnyObject!
    
    public var onHeader: ((Void) -> (Void))?
    public var onHeaderComplete: ((AnyObject) -> Void)?
    public var onBody: ((Void) -> Void)?
    public var onBodyComplete: ((Void) -> Void)?
    
    
    private var contentLength: Int32 = 0
    
    
    public init(){
        contentLength = 0
    }
    
    
    public func execute(){
        
    }
    
}
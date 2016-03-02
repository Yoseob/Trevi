//
//  Layer.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 2..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
public class Layer {
    
    private var handle: HttpCallback?
    public var path: String! = ""
    public var regexp: RegExp!
    public var name: String!
    public var route: Route?
    public var method: HTTPMethodType! = .UNDEFINED
    
    public var keys: [String]? // params key ex path/:name , name is key
    public var params: [String: AnyObject]?
    
    public init(path: String ,name: String? = "function", options: Option? = nil, fn: HttpCallback){
        setupAfterInit(path, opt: options, name: name, fn: fn)
        
    }
    public init(path: String, options: Option? = nil, module: Middleware){
        setupAfterInit(path, opt: options, name: module.name.rawValue, fn: module.handle)
        
    }
    private func setupAfterInit(p: String, opt: Option? = nil, name: String?, fn: HttpCallback){
        self.handle = fn
        self.path = p
        self.name = name
        //create regexp
        regexp = self.pathRegexp(path, option: opt)
        
        if path == "/" && opt?.end == false {
            regexp.fastSlash = true
        }
    }
    
    private func pathRegexp(path: String, option: Option!) -> RegExp{
        // create key, and append key when create regexp
        keys = [String]()
        
        if path.length() > 1 {
            for param in searchWithRegularExpression(path, pattern: ":([^\\/]*)") {
                keys!.append(param["$1"]!.text)
            }
        }
        
        return RegExp(path: path)
    }
    
    public func handleRequest(req: IncomingMessage , res: ServerResponse, next: NextCallback){
        let function = self.handle
        function!(req,res,next)
    }
    
    public func match(path: String?) -> Bool{
        
        guard path != nil else {
            self.params = nil
            self.path = nil
            return false
        }
        
        guard (self.regexp.fastSlash) == false else {
            self.path = ""
            self.params = [String: AnyObject]()
            return true
        }
        
        var ret: [String]!  = self.regexp.exec(path!)
        
        guard ret != nil else{
            self.params = nil
            self.path = nil
            return false
        }
        
        self.path = ret[0]
        self.params = [String: AnyObject]()
        ret.removeFirst()
        
        var idx = 0
        var key: String! = ""
        for value in ret {
            key = keys![idx++]
            if key == nil {
                break
            }
            params![key] = value
            key = nil
        }
        
        return true
    }
    
}


//
//  Route.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi


public class Route{
    public var stack = [Layer!]()
    public var path: String?
    public var methods = [HTTPMethodType]()
    public var method: HTTPMethodType!
    public var dispatch: HttpCallback? {
        didSet{
            let layer = Layer(path: "", name: "anonymous", options: Option(end: true), fn: self.dispatch!)
            if method != nil{
                layer.method = method
                method = nil
            }else{
                layer.method = .UNDEFINED
            }
            
            self.stack.append(layer)
        }
    }
    
    public init(method: HTTPMethodType, _ path: String){
        self.path = path
        self.methods.append(method)
    }
    
    public func dispatchs(req: IncomingMessage,res: ServerResponse,next: NextCallback?){
        
        var idx = 0
        let stack = self.stack
        
        guard stack.count > 0 else {
            return next!()
        }
        
        req.route = self
        let method = req.method
        
        func nextHandle(){
            guard stack.count > idx else {
                return next!()
            }
            
            let layer: Layer! = stack[idx++]
            
            guard layer != nil  else{
                return next!()
            }
            
            if (layer.method != nil) && (layer.method != method){
                return nextHandle()
            }
            
            layer.handleRequest(req, res: res, next: nextHandle)
        }
        nextHandle()
    }
    
    public func handlesMethod(method: HTTPMethodType) -> Bool{
        for _mathod in methods {
            if method == _mathod {
                return true
            }
        }
        
        return false
    }
    
    public func options() -> [HTTPMethodType] {
        return self.methods
    }
    
}

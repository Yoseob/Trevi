//
//  Router.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 30..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi

/*
    One of the Middleware class to the path to ensure that able to handle the user defined url
    However, it's not find the path to the running is trevi all save the path at this class when the server is starting on the go.
    so it is like lazyRouter

*/

public class Router: Middleware{
    public var methods = [HTTPMethodType]()
    public var  name: MiddlewareName = .Router
    private var stack = [Layer]()
    
    public init(){}
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback? ) {
        
        var idx = 0
        var options = [HTTPMethodType:Int]()
        var removed = ""
        var slashAdd = false
        
        var parantParams = req.params
        var parantUrl = req.baseUrl
        var done = next
        
        req.baseUrl = parantUrl
        req.originUrl = req.originUrl.length() == 0 ? req.url : req.originUrl
        
        func trimPrefix(layer: Layer , layerPath: String, path: String){
            
            let nextPrefix: String! = path == layerPath ? "/" : path.substring(layerPath.length(), length: 1)
            
            if nextPrefix != nil && nextPrefix != "/" {
                done!()
                return
            }
            
            if layerPath.length() > 0 {
                removed = layerPath
                req.baseUrl = parantUrl
                let removedPathLen = removed.length()
                
                req.url = req.url == layerPath ? "/": path.substring(removedPathLen, length: path.length() - removedPathLen)
                
                if req.url.substring(0, length: 1) != "/" {
                    req.url = ("/"+req.url)
                    slashAdd = true
                }
                req.baseUrl = removed
            }
            
            layer.handleRequest(req, res: res, next: nextHandle)
        }
        
        func nextHandle(){
            
            if removed.length() != 0 {
                req.baseUrl = parantUrl
                removed = ""
            }
            
            if idx > self.stack.count{
                return
            }
            
            let path = getPathname(req)
            var layer: Layer!
            var match: Bool!
            var route: Route!
            
            while match != true && idx < stack.count{
                layer = stack[idx]
                idx += 1
                match = matchLayer(layer, path: path)
                route = layer.route
                
                if (match != true) || (route == nil ) {
                    continue
                }
                
                let method = req.method
                let hasMethod = route.handlesMethod(method)
                
                if hasMethod && method == .OPTIONS {
                    for method in route.options() {
                        options[method] = 1
                    }
                }
                
            }
            
            if match == nil || match == false {
                return done!()
            }
            
            if route != nil {
                req.route = route
            }
            
            if layer.params != nil{
                var params = layer.params
                if parantParams != nil {
                    params = mergeParams(layer.params, src: parantParams)
                }
                req.params = params
            }
            
            let layerPath = layer.path
            
            #if os(Linux)
                poccessParams(layer, paramsCalled: StringWrapper(string: ""), req: req, res: res) {  err in
                    if err != nil {
                        return nextHandle()
                    }
                    
                    if route != nil {
                        return layer.handleRequest(req, res: res, next: nextHandle)
                    }
                    
                    trimPrefix(layer, layerPath: layerPath, path: path)
                }
            #else
                poccessParams(layer, paramsCalled: "", req: req, res: res) {  err in
                    if err != nil {
                        return nextHandle()
                    }
                    
                    if route != nil {
                        return layer.handleRequest(req, res: res, next: nextHandle)
                    }
                    
                    trimPrefix(layer, layerPath: layerPath, path: path)
                }
            #endif
        }
        nextHandle()
    }
    
    private func mergeParams(dest: [String: String]? , src: [String: String]?) -> [String: String]?{
        var _dest = dest
        for (k,v) in src! {
            _dest![k] = v
        }
        return _dest
    }
    
    private func poccessParams(layer: Layer, paramsCalled: AnyObject, req: IncomingMessage, res: ServerResponse, cb:((String?)->())){
        cb(nil)
    }
    
    private func matchLayer(layer: Layer , path: String) -> Bool{
        return layer.match(path)
    }
    
    private func getPathname(req: IncomingMessage) -> String{
        //should parsing req.url
        return req.url!
    }
    
    func use(path: String? = "/",  md: Middleware){
        stack.append(Layer(path: path!, options: Option(end: false), module: md))
    }
    
    func use(fns: HttpCallback...){
        for fn in fns {
            stack.append(Layer(path: "/", name: "function", options: Option(end: false), fn: fn))
        }
    }
    
    
    public func all ( path: String, _ callback: HttpCallback... ) {
        
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func get (path: String, _ callback: HttpCallback) {
        boundDispatch(path, callback , .GET)
    }
    /**
     * Support http ver 1.1/1.0
     */

    public func post ( path: String, _ middleWare: Middleware? = nil, _ callback: HttpCallback ) {
        boundDispatch(path, callback, .POST, middleWare)
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func put ( path: String, _ callback: HttpCallback ) {
        boundDispatch(path, callback , .PUT)
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func head ( path: String, _ callback: HttpCallback... ) {
        
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func delete ( path: String, _ callback: HttpCallback... ) {
        
    }
    
    
    private func boundDispatch(path: String, _ callback: HttpCallback, _ method: HTTPMethodType , _ md: Middleware? = nil ){
        let route = Route(method: method, path)
        if let middleware = md {
            
            let newMiddleWare = Layer(path: "/", options: Option(end: false), module: middleware)
            newMiddleWare.method = method 
            route.stack.append(newMiddleWare)
        }
        
        methods.append(method)
        route.method = method
        route.dispatch = callback
        let layer = Layer(path: path, name: "bound dispatch", options: Option(end: true), fn: route.dispatchs)
        layer.route = route
        stack.append(layer)
    }
    
}


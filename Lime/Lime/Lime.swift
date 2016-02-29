//
//  Trevi.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 12. 7..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation
import Trevi
/*
    One of the Middleware class to the path to ensure that able to handle the user defined url
    However, it's not find the path to the running is trevi all save the path at this class when the server is starting on the go.
    This class is real class router's functioning.
*/


public enum _MiddlewareName: String {
    case Query           = "query"
    case Err             = "error"
    case Undefined       = "undefined"
    case Favicon         = "favicon"
    case BodyParser      = "bodyParser"
    case Logger          = "logger"
    case Json            = "json"
    case CookieParser    = "cookieParser"
    case Session         = "session"
    case SwiftServerPage = "swiftServerPage"
    case Trevi           = "trevi"
    case Router          = "router"
    case ServeStatic     = "serveStatic"
    // else...
}

public protocol _Middleware{
    
    var name: _MiddlewareName { get set }
    func handle(req: IncomingMessage,res: ServerResponse,next: NextCallback?) -> ()
}


public class _Route{
    private var stack = [Layer]()
    public var path: String?
    public var methods = [HTTPMethodType]()
    public var dispatch: HttpCallback? {
        didSet{
            let layer = Layer(path: path!, name: "function", options: Option(end: true), fn: self.dispatch!)
            self.stack.append(layer)
        }
    }
    
    public func dispatchs(req: IncomingMessage,res: ServerResponse,next: NextCallback?){
        print("dispatchs")
    }
    
    public func handlesMethod(method: HTTPMethodType){

    }
    
    public init(method: HTTPMethodType, _ path: String){
        self.path = path
        self.methods.append(method)
    }
}

public struct Option{
    public var end: Bool = false
    public init(end: Bool){
        self.end = end
    }
}

public class RegExp{
    public var fastSlash: Bool! // middleware only true
    public var source: String! //regexp
    public init(){
        self.fastSlash = false
        self.source = ""
    }
}

public class Layer {
    
    private var handle: HttpCallback?
    public var path: String!
    public var regexp: RegExp!
    public var name: String!
    public var route: _Route?
    public var params: [String: AnyObject]?
    
    public init(path: String ,name: String? = nil, options: Option? = nil, fn: HttpCallback){
        handle = fn
        self.path = path
        if let name = name{
            self.name = name
        }
    }
    public init(path: String, options: [String:String]? = nil, module: _Middleware){
        handle = module.handle
        self.path = path
        self.name = module.name.rawValue
        
        //create regexp
        // temp 
        if path == "/" {
            regexp = RegExp()
            regexp.fastSlash = true
        }
        
    }
    
    public func handleRequest(req: IncomingMessage , res: ServerResponse, next: NextCallback){
        let function = self.handle
        function!(req,res,next)
    }
    public func match(path: String?) -> Bool{
        
        if path == nil {
            self.params = nil
            self.path = nil
            return false
        }
        
        if self.regexp!.fastSlash! {
            self.path = ""
            self.params = [String: AnyObject]()
            return true
        }
        
        return true
    }
}

//test middleware
class Query: _Middleware {
    var  name: _MiddlewareName = .Query
    init(){
    }
    
    func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback?) {
        print(name)
        next!()
    }
}


public class _Router: _Middleware{
    public var methods = [HTTPMethodType]()
    public var  name: _MiddlewareName = .Router
    private var stack = [Layer]()
    
    public init(){}
    public func handle(req: IncomingMessage, res: ServerResponse, next: NextCallback? ) {
        print(name)
        
        var idx = 0
        
        func trimPrefix(layer: Layer , layerPath: String, path: String){
            // do...what ...
            
            layer.handleRequest(req, res: res, next: nextHandle)
        }
        
        func nextHandle(){
           
            if idx > self.stack.count{
                return
            }
        
            let path = getPathname(req)
            
            var layer: Layer!
            var match: Bool!
            var route: _Route!
        
            while match != true && idx < stack.count{
                layer = stack[idx++]
                match = matchLayer(layer, path: path)
                route = layer.route
                
                if (match != true) || (route == nil ) {
                    continue
                }
                route.handlesMethod(HTTPMethodType(rawValue: req.method)!)
            }
            
            if match == false {
                // return done()
            }
            
            if route != nil {
                //req.route = route
            }
            
            let layerPath = layer.path
            
            self.poccessParams(layer, paramsCalled: "", req: req, res: res) {  err in
                if err != nil {
                    return nextHandle()
                }
                
                if route != nil {
                    layer.handleRequest(req, res: res, next: nextHandle)
                }
                trimPrefix(layer, layerPath: layerPath, path: path)
            }
        }
        nextHandle()

    }
    

    
    private func poccessParams(layer: Layer, paramsCalled: AnyObject, req: IncomingMessage, res: ServerResponse, cb:((String?)->())){
        cb(nil)
    }
    
    private func matchLayer(layer: Layer , path: String) -> Bool{
        return layer.match(path)
    }
    
    private func getPathname(req: IncomingMessage)-> String{
        //should parsing req.url
        return req.path
    }
    
    func use(path: String? = "/",  md: _Middleware){
        stack.append(Layer(path: path!, module: md))
    }
    
    func use(fns: HttpCallback...){
        for fn in fns {
            stack.append(Layer(path: "/", name: "function", options: nil, fn: fn))
        }
    }

    
    public func all ( path: String, _ callback: HttpCallback... ) {
        
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func get (path: String, _ callback: HttpCallback) {
        bind(path, callback , .GET)
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func post ( path: String, _ callback: HttpCallback ) {
        bind(path, callback , .POST)
    }
    /**
     * Support http ver 1.1/1.0
     */
    public func put ( path: String, _ callback: HttpCallback ) {
        bind(path, callback , .PUT)
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
    
    private func bind(path: String, _ callback: HttpCallback, _ method: HTTPMethodType){
        methods.append(method)
        let route = _Route(method: method, path)
        route.dispatch = callback
        let layer = Layer(path: path, name: "function", options: Option(end: true), fn: route.dispatchs)
        layer.route = route
        stack.append(layer)
    }

}

public class _Routable{
    private var _router: _Router!
    
    public func use(path: String, _ middleware: _Require){
        let r = middleware.export()
        _router.use(path, md: r)
    }
    
    //just function
    public func use(fn: HttpCallback){
        _router.use(fn)
    }
    
}


public class Lime : _Routable{
    
    public var router: _Router{
        let r = self._router
        if let r = r {
            return r
        }
        return _Router()
    }
    
    public override init () {
        
        super.init()
    }
    
    private func lazyRouter(){
        guard _router == nil else {
            return
        }
        _router = _Router()
        _router.use(md: Query())
    }
    
    public func use(middleware: _Middleware) {
        lazyRouter()
        _router.use(md: middleware)
    }

}


extension Lime: ApplicationProtocol{
    public func createApplication() -> Any {
        return self._router.handle
    }
}


public protocol _Require{
    func export() -> _Router
}

public class Root{
    
    private let lime = Lime()
    private var router: _Router!
    public init(){
        router = lime.router
        
        router.get("/") { ( req , res , next) -> Void in
            print("root get")
        }
    }
}

extension Root: _Require{
    public func export() -> _Router {
        return self.router
    }
}





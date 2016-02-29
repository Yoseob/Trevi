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
            let layer = Layer(path: "", name: "anonymous", options: Option(end: true), fn: self.dispatch!)
            self.stack.append(layer)
        }
    }
    
    public init(method: HTTPMethodType, _ path: String){
        self.path = path
        self.methods.append(method)
    }

    public func dispatchs(req: IncomingMessage,res: ServerResponse,next: NextCallback?){

        for layer in stack {
            layer.handleRequest(req, res: res, next: next!)
        }
        
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
    public func exec(path: String) -> [String]?{
        var result = [String]()
        result.append(path)
        
        
        
        return result
    }
}

public class Layer {
    
    private var handle: HttpCallback?
    public var path: String! = ""
    public var regexp: RegExp!
    public var name: String!
    public var route: _Route?
    
    public var keys: [String]? // params key ex path/:name , name is key
    public var params: [String: AnyObject]?
    
    public init(path: String ,name: String? = "function", options: Option? = nil, fn: HttpCallback){
        print("path : \(path), name : \(name!) , option: \(options)")
        setupAfterInit(path, opt: options, name: name, fn: fn)
        
    }
    public init(path: String, options: Option? = nil, module: _Middleware){
        print("path : \(path), name : \(module.name) , option: \(options)")
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
    
    private func pathRegexp(path: String,option: Option!) -> RegExp{
        keys = [String]() // create key, and append key when create regexp
        
        // temp
        return RegExp()
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

        for _ in ret {
            //keys made when make regexp
            //so fill params based on key, ret,
            // !!!!!! keys , ret both should be same index per item
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
        var options = [HTTPMethodType:Int]()
        var removed = ""
        var slashAdd = false
        
        var parantParams = req.params
        var parantUrl = req.baseUrl
        
        req.baseUrl = parantUrl
        req.originUrl = req.originUrl.length() == 0 ? req.url : req.originUrl
        func trimPrefix(layer: Layer , layerPath: String, path: String){
            
            let nextPrefix: String! = path.substring(layerPath.length(), length: 1)
            
            if nextPrefix != nil && nextPrefix != "/" {
                //done error
                return
            }
            
            // do...what ...
            if layerPath.length() > 0 {
                removed = layerPath
                req.baseUrl = parantUrl
                let removedPathLen = removed.length()
                req.url = path.substring(removedPathLen-1, length: path.length() - removedPathLen)
                
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
                //req.url = ""
                removed = ""
            }
            
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
                
                let method = HTTPMethodType(rawValue: req.method)!
                let hasMethod = route.handlesMethod(method)
                
                if hasMethod && method == .OPTIONS {
                    appendMethods(&options, src: route.options())
                }
                
            }
            
            if match == nil || match == false {
//                 return done()
                print("done")
                
            }
            
            if route != nil {
                req.route = route
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
    
    private func appendMethods(inout dest: [HTTPMethodType:Int], src: [HTTPMethodType]){
        for method in src {
            dest[method] = 1
        }
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
    public func post ( path: String, _ callback: HttpCallback ) {
        boundDispatch(path, callback , .POST)
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
    
    private func boundDispatch(path: String, _ callback: HttpCallback, _ method: HTTPMethodType){
        methods.append(method)
        let route = _Route(method: method, path)
        route.dispatch = callback
        let layer = Layer(path: path, name: "bound dispatch", options: Option(end: true), fn: route.dispatchs)
        layer.route = route
        stack.append(layer)
    }

}

public class _Routable{
    private var _router: _Router!
    
    public func use(path: String = "/", _ middleware: _Require){
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
        
        router.get("/index") { ( req , res , next) -> Void in
            print("root get")
            next!()
            
        }
        router.get("/lime") { ( req , res , next) -> Void in
            print("lime get")
            next!()
        }
        
    }
}

extension Root: _Require{
    public func export() -> _Router {
        return self.router
    }
}


//extention incomingMessage for lime 
extension IncomingMessage {
    public var route: Route {
        get {
            return (self._route  as? Route)!
        }
        set{
            self._route = newValue
        }
    }
}



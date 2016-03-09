//
//  TreviServer.swift
//  Trevi
//
//  Created by LeeYoseob on 2016. 3. 4..
//  Copyright © 2016년 LeeYoseob. All rights reserved.
//

import Foundation



public class HttpServer: Net{
    
    private var parsers = [uv_stream_ptr:HttpParser!]()
    
    private var requestListener: Any!
    
    init(requestListener: Any!){
        super.init()
        self.requestListener = requestListener
        
        self.on("request", requestListener) // Not fixed calling time
        
        self.on("listening", onlistening) //when server start listening client socket, Should called this callback
        
        self.on("connection", connectionListener) // when Client Socket accepted
    }
    
    deinit{
        parsers.removeAll()
    }
    
    func onlistening(){
        print("Http Server starts ip : \(ip), port : \(port).")
        
        switch requestListener {
        case let ra as ApplicationProtocol:
            let eventName = "request"
            
            self.removeEvent(eventName)
            self.on(eventName, ra.createApplication())
            break
        default:
            break
        }
    }
    
    private func parser(socket: Socket) -> HttpParser{
        return parsers[socket.handle]!
    }
    
    func connectionListener(sock: AnyObject){
        
        let socket = sock as! Socket
        
        func parserSetup(){
            
            parser(socket).onHeader = {
            }
            
            parser(socket).onHeaderComplete = { info in
                let incoming = IncomingMessage(socket: self.parser(socket).socket)
                
                incoming.header = info.header
                incoming.httpVersionMajor = info.versionMajor
                incoming.httpVersionMinor = info.versionMinor
                incoming.url = info.url
                incoming.method = HTTPMethodType(rawValue: info.method)
                incoming.hasBody = info.hasbody
                
                self.parser(socket).incoming = incoming
                self.parser(socket).onIncoming!(incoming)
            }
            
            parser(socket).onBody = { body in
                let incoming = self.parser(socket).incoming
                if body.length() > 0 {
                    incoming.push(body)   
                }
            }
            
            parser(socket).onBodyComplete = {
                let incoming = self.parser(socket).incoming
                incoming.emit("end")                
            }
        }
        
        parsers[socket.handle] = HttpParser()
        let _parser = parser(socket)
        _parser.socket = socket
        parserSetup()
        
        socket.ondata = { data, nread in
            if let _parser = self.parsers[socket.handle] {
                _parser.execute(data,length: nread)
            }else{
                print("no parser")
            }
        }
        
        socket.onend = {
            
            var _parser = self.parsers[socket.handle]
            _parser!.onBody = nil
            _parser!.onBodyComplete = nil
            _parser!.onHeader = nil
            _parser!.onIncoming = nil
            _parser!.onHeaderComplete = nil
            _parser!.socket = nil
            _parser!.incoming = nil
            _parser = nil
            self.parsers.removeValueForKey(socket.handle)
            
        }
        
        parser(socket).onIncoming = { req in
            
            let res = ServerResponse(socket: req.socket)
            res.socket = req.socket
            res.connection = req.socket
            
            res.httpVersion = "HTTP/"+req.version
            if let connection = req.header[Connection] where connection == "keep-alive" {
                res.header[Connection] = connection
                res.shouldKeepAlive = true
            }else{
                res.header[Connection] = "close"
                res.shouldKeepAlive = false
            }
            res.req = req
            
            self.emit("request", req ,res)
            
            return false
        }
        
    }
}


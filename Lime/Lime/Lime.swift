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

public class Lime : RoutAble{
    
//    private let httpParser = LimePrepare()
    
    public  override init () {
        super.init()
        registerRequestEventListener()
    }
    
    public override func use (var path : String = "" ,  _ module : RoutAble... ) -> RoutAble {
        self.use(router)
        if path == "/"{
            path = ""
        }
        return makeChildsRoute (path, module: module )
    }

    private func registerRequestEventListener() {
        eventListener = MainListener()
        eventListener!.on("data") { info in
//            self.httpParser.appendData(info)
        }
    }
}


public class tLime: RoutAble{
    
    //    private let httpParser = LimePrepare()
    
    public  override init () {
        super.init()
        registerRequestEventListener()
    }
    
    public override func use (var path : String = "" ,  _ module : RoutAble... ) -> RoutAble {
        self.use(router)
        if path == "/"{
            path = ""
        }
        return makeChildsRoute (path, module: module )
    }
    
    private func registerRequestEventListener() {
        eventListener = MainListener()
        eventListener!.on("data") { info in
            //            self.httpParser.appendData(info)
        }
    }
}



extension tLime: ApplicationProtocol{
    public func createApplication() -> Any {
        
        func handle(req: IncomingMessage,res: ServerResponse,next: NextCallback){
//            self.handleRequest(<#T##request: Request##Request#>, <#T##response: Response##Response#>)
        }
        
        return handle
    }
}
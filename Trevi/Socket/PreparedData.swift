//
//  PreparedData.swift
//  IWas
//
//  Created by LeeYoseob on 2015. 11. 24..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

import Foundation


class PreparedData {

    var requestdata: NSData!
    init (requestData : NSData){
        self.requestdata = requestData;
    }
    
    func prepareReqAndRes(socket :SwiftSocket) -> (Request , Response){
        return (setupRequest(), setupResponse(socket))
    }
    
    private func setupRequest() -> Request{
        var resultRequest : Request = requestFactory(requestdata)
    
//        let contentLengthString = resultRequest.header["Content-Length"]!
//        if let contentLengthInt(contentLengthString) > 0 where{
//            
//        }
        return resultRequest
    }
    
    private func requestFactory(data : NSData) ->Request{

        return Request(data)
    }
    
    private func setupResponse(socket:SwiftSocket) ->Response{
        let res = Response(socket: socket)
        res.statusCode = 200
        return res
    }
    
}


//Optional("GET / HTTP/1.1\r\n
//    Host: localhost:8080\r\n
//    Connection: keep-alive\r\n
//    Cache-Control: max-age=0\r\n
//    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/  //*;q=0.8\r\n
//        Upgrade-Insecure-Requests: 1\r\n
//        User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36\r\n
//        Accept-Encoding: gzip, deflate, sdch\r\n
//        Accept-Language: ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4
//        s\r\n\r\n")

//Optional("POST / HTTP/1.1\r\n
//        Host: localhost:8080\r\n
//        Connection: keep-alive\r\n
//        Content-Length: 306\r\n
//        Cache-Control: no-cache\r\n
//        Origin: chrome-extension://fhbjgbiflinjbdggehcddcbncdddomop\r\n
//        Content-Type: application/json\r\n
//        User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/46.0.2490.80 Safari/537.36\r\n
//        Postman-Token: 86be0c01-9380-644d-4faa-d2a47062500f\r\n
//        Accept: */*\r\n
//    Accept-Encoding: gzip, deflate\r\n
//    Accept-Language: ko-KR,ko;q=0.8,en-US;q=0.6,en;q=0.4\r\n\r\n
//    {\n            \"iotProviderUserId\" : \"abc@abc.abc\",\n            \"deviceId\" :\"7e870bec-57e2-42e1-a937-d0cd4ded22ba\",\n            \"productName\" :\"Philps Hue\",\n            \"capability\" : \"switchLevel\",\n            \"command\" : \"setLevel\",\n            \"parameterList\":[{\"parameter\":\"level\",\"value\":828282828}]\n }")



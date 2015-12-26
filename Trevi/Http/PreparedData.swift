//
//  PreparedData.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 24..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

typealias ReceivedParams = (length: Int, buffer: UnsafePointer<CChar>)
import Foundation

/*

    PreparedData is make request and response after read all of data from client

*/
class PreparedData {

    init(){
    }

    var requestHandler :RequestHandler?
    private var content_length = 0
    var socket : TreviSocket?
    private var req : Request?


    func appendReadData(params : ReceivedParams) -> (Int,Int){
        
        let (strData,_) = String.fromCStringRepairingIllFormedUTF8(params.buffer)
        let data = strData! as String
        var headerLength = 0;
        print(data)
        //header
        if data.containsString("HTTP/1."){
            req = nil
            req = setupRequest(data)
            if let contentLength = req?.header[Content_Length]{
                content_length =  Int(contentLength)!
                headerLength = params.length
            }
        }else{
            //read file
            //req.body
            /*
            
            if content_length > config.max_post_size {
                read file
            }else{
                read stack memory
            }
            
            */
            req?.body.appendBytes(params.buffer, length: params.length)
        }
        return (content_length,headerLength)
    }
    
    func handleRequest(socket : TreviSocket ){
        let res = setupResponse(socket)
        requestHandler?.beginHandle(self.req!, res)
    }
    
    func dInit(){
        content_length = 0
    }
 
    /**
     * Factory Methed to make reqeust and response
     *
     *
     * @param { TreviSocket} socket
     * @return {( Request, Response )}
     * @private
     */
    

    private func setupRequest ( hData: String ) -> Request {
        return Request( hData )
    }

    private func setupResponse ( socket: TreviSocket ) -> Response {
        let res = Response( socket: socket )
        res.method = self.req!.method
        
        //connection header
        if let connection = req?.header[Connection]{
            res.header[Connection] = connection
        }
        
        return res
    }

}

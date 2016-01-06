//
//  PreparedData.swift
//  Trevi
//
//  Created by LeeYoseob on 2015. 11. 24..
//  Copyright © 2015년 LeeYoseob. All rights reserved.
//

public typealias ReceivedParams = (buffer: UnsafeMutablePointer<CChar>, length: Int)
import Foundation

/*

    PreparedData is make request and response after read all of data from client

*/
public class PreparedData {

    init(){
    }

    // If completed with a request to begin addressing delegate
    public var requestHandler :RequestHandler?
    
    //The content-length of the body
    private var content_length = 0
    
    private var req : Request?
    
    var filemanager  = File()
    
    
    /**
     Functions that can make with one request a function been divided into several
     
     - Parameter path: Data received and length
     
        Examples:
            public func operateCommand ( params: MiddlewareParams ) -> Bool {
                return false
             }

     - Returns: {(Int,Int)} content-length,header-length

     */
    func appendReadData(params : ReceivedParams) -> (Int,Int){

        let (strData,_) = String.fromCStringRepairingIllFormedUTF8(params.buffer)
        var data = strData! as String
        var headerLength = 0;
        //header
        if data.containsString("HTTP/1."){
            req = nil
            req = setupRequest(data)
            if let contentLength = req?.header[Content_Length]{
                content_length =  Int(contentLength)!
                headerLength = params.length
            }

            if req!.header[Content_Length] != nil && req!.bodyFragments.count == 0  {
                let headerList = req!.headerString.componentsSeparatedByString(CRLF)
                var buff = String()
                var flag = false
                
                for line in headerList{
                    if line.length() == 0 {
                        flag = true
                    }
                    if flag && line.length() > 0{
                        buff += line
                        buff += CRLF
                    }
                }
                data = buff
            }
        }
        dispatchBodyData(data)
        return (content_length,headerLength)
    }
    
    
    /**
     Function with which to data rather than parsing through
     
     - Parameter path: At the request of a string body
     
     - Returns: Void
     
     */
    func dispatchBodyData(bodyFragment : String){
        req?.bodyFragments.append(bodyFragment)
    }
    
    /**
     Running time with response to complete function to listen to the data of the request.

     
     - Parameter path: A socket for response
     
     - Returns: Void
     
     */
    func handleRequest(socket : ClientSocket ){
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

    private func setupResponse ( socket: ClientSocket ) -> Response {
        let res = Response( socket: socket )
        res.method = self.req!.method
        
        //connection header
        if let connection = req?.header[Connection]{
            res.header[Connection] = connection
        }
        
        return res
    }

}

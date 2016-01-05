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

    public var requestHandler :RequestHandler?
    private var content_length = 0
    private var req : Request?
    var filemanager  = File()
    
    var testData : NSMutableData?
    
    func appendReadData(params : ReceivedParams) -> (Int,Int){

        let (strData,_) = String.fromCStringRepairingIllFormedUTF8(params.buffer)
        var data = strData! as String
        var headerLength = 0;
        //header
        if data.containsString("HTTP/1."){
            req = nil
            req = setupRequest(data)
            testData = NSMutableData()
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
    
    func dispatchBodyData(bodyFragment : String){
        req?.bodyFragments.append(bodyFragment)
    }
    
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

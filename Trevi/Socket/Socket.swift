

typealias ReceivedRequestCallback = ((Request,Response,Socket) -> Bool)

enum SocketErrors: ErrorType {
    case ListenError
    case PortUsedError
}

protocol SocketServer {

    func startOnPort(p: Int) throws
    func disconnect()
    
    var receivedRequestCallback: ReceivedRequestCallback? { get set }
}

protocol Socket {
    func sendData(data: NSData)
}

// Mark: SwiftSocket Implementation of the Socket and SocketServer protocol


import SwiftSockets

public struct SwiftSocket: Socket {
    
    let socket: ActiveSocketIPv4
    
    func sendData(data: NSData) {
        
        socket.write(dispatch_data_create(data.bytes, data.length, dispatch_get_main_queue(), nil))
        socket.close()
    }
}

class SwiftSocketServer: SocketServer {
    
    var socket: PassiveSocketIPv4!
    
    var receivedRequestCallback: ReceivedRequestCallback?
    
    func startOnPort(p: Int) throws {
        
        guard let socket = PassiveSocketIPv4(address: sockaddr_in(port: p)) else { throw SocketErrors.ListenError }
        socket.listen(dispatch_get_global_queue(0, 0)) {
            socket in
            
            socket.onRead {
                newsock, length in
                
                socket.isNonBlocking = true
                
                var initialData: NSData?
                let (size, data, _) = newsock.read()
                
                if size > 0 {
                    initialData = NSData(bytes: data, length: size)
                }

                if let initialData = initialData {
                    
                    let preparedData = PreparedData(requestData: initialData)
                    let socket = SwiftSocket(socket: socket)
                    let (req , res) = preparedData.prepareReqAndRes(socket);
                    self.receivedRequestCallback?(req,res,socket)
                }
            }
        }
        
        self.socket = socket
    }
    
    func disconnect() {
        self.socket.close()
    }
}

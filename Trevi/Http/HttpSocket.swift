typealias HttpCallback = ( ( Request, Response, TreviSocket ) -> Bool )

public class TreviSocket {

    var socket: ConnectedSocket<IPv4>!
    
    init(socket : ConnectedSocket<IPv4>){
        self.socket = socket
    }

    func sendData ( data: NSData ) {

        socket.write (data.bytes, length: data.length, queue: dispatch_get_main_queue())
      
        socket.close ()
    }
}

class TreviSocketServer {

    var socket: ListenSocket<IPv4>!

    var httpCallback: HttpCallback?

    func startOnPort ( p: Int ) throws {

        guard let socket = ListenSocket<IPv4> ( address: IPv4 ( port: p )) else {
            // Should handle Listener error
            return
        }
        socket.listen (true) {
            client, length in

            var initialData: NSData?
            let (size, data, _ ) = client.read()

            if size > 0 {
                initialData = NSData ( bytes: data, length: size )
            }
            
            if let initialData = initialData {
                let preparedData = PreparedData ( requestData: initialData )
                let httpClient       = TreviSocket ( socket: client )
                let (req, res)   = preparedData.prepareReqAndRes ( httpClient )
                self.httpCallback! ( req, res, httpClient )
            }
        }

        self.socket = socket
    }

    func disconnect () {
        self.socket.close ()
    }
}

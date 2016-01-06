

## Trevi
Trevi is a minimal and flexible Swift web application server that provides Swift server page and MVC module.<br>
Trevi uses and event-driven, non-blocking I/O model based on GCD.<br>
Swift 2.0 and xCode 7.1.1 required or latest release.
 
## Examples
```swift
import Trevi
let server = Http ()
do {
    try server.createServer( { req , res in
        return res.send("hello trevi!")
    }).listen(8080)
} catch {
    //error
}
```

OR

```swift

import Trevi

let server = Http ()
let trevi = Trevi.sharedInstance ()
let lime   = Lime ()

lime.use(BodyParser())
lime.use(Favicon())
lime.use(SwiftServerPage())
lime.use(trevi) // it is important to routing
lime.use(){ req, res in
    res.status = 404
    return res.send ("404 Pages Not Found")
}

do {
    try server.createServer ( lime ).listen ( 8080 )
} catch {
    //error
}
```

lime class 
```swift

import Trevi

public class Lime: RouteAble {

    override init () {
        super.init ()
    }

    public override func prepare() {

        let lime = trevi.store(self)
    
        lime.get ( "/trevi" ) { req, res in
            let msg = "Hello Trevi!"
            return res.send ( msg )
        }

        lime.get ( "/", { req, res in
            // Do any..
            return false
        }, { req, res in
            return res.render("trevi.ssp", args: [ "title" : "Trevi" ])
        })

        lime.use ( "/yoseob", Index () )

        lime.get( "/param/:arg", { req, res in
            var msg = "Request path : \(req.path)<br>"
            msg += "Found parameter : <br>\(req.params)"
            return res.send ( msg )
        })

        lime.get("/redir"){ req , res in
            return res.redirect(url: "http://127.0.0.1:8080/trevi")
        }
    }
}

```

### CocoaPods 
### Carthage
### Youtube
https://youtu.be/W6hPkevipX4


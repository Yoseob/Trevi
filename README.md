

## Trevi
Fast, light web application server framwork for Swift. Trevi uses an event-driven, non-blocking I/O model based on libuv (https://github.com/libuv/libuv).<br>
Trevi refers to node.js core modules and makes Trevi core modules similary to support node.js features. Trevi also hopes that node.js developers easily use and develop Trevi. <br><br>
Lime is improved web framework for Trevi, and Lime refers to express. (Lime does not support many core modules in express yet.)


## Build Instructions

### OS X (recommended)
For Debug builds (recommended) run:
```
$ make all
```

For Release builds run:
```
$ make all COMPILE_MODE=Release
```

### Ubuntu
Trevi is not working on ubuntu yet, but it can be build soon.

### Running tests
For testing Trevi, use Xcode and build the project


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


# Simple

A library that makes it very simple to set up a backend using MongoDB, Vapor (HTTP) routing and Models using Genome.

## Simple example 

```swift
import Simple

let app = try! SimpleApplication(databaseUrl: "mongodb://127.0.0.1:27017", database: "simple")

struct User: Model {
    static let collection = app.collection("users")
    var id: ObjectId
    var username: String
    var age: Int
    var metadata: Document
    
    func serialize() throws -> Document {
        return [
                   "username": ~username,
                   "age": ~age
        ]
    }
    
    init(with map: Map) throws {
        id = try ObjectId(try map.extract("_id"))
        username = try map.extract("username")
        age = try map.extract("age")
        metadata = ["special": true]
    }
}

app.get("user", User.self) { request, user in
    return try user.toJson().serialize()
}

app.start(port: 8080)
```

## Featuring RequestInitializable

```swift
enum LoginError: ErrorProtocol {
    case missingAuthenticationDetails
}

class LoginRequest: RequestInitializable {
    let request: Request
    let user: User?
    var authenticated = false

    required init(request: Request) throws {
        self.request = request
        
        guard let username = request.data["username"].string, let password = request.data["password"].string else {
            throw LoginError.missingAuthenticationDetails
        }

        self.user = try User.findOne(matching: "username" == ~username)

        if let user = user {
            authenticated = user.password == password
        }
    }
}

app.get("login") { (loginRequest: LoginRequest) in
    if let user = loginRequest.user where loginRequest.authenticated {
        return "Welcome \(user.username)"
    }

    return "Login failed"
}
```

## Supports reflection to reduce boilerplate

```swift
struct User: ReflectableModel {
    static let collection = app.collection("users")
    var _id: ObjectId
    var metadata: Document
    
    var username: String
    var age: Int
    
    // Plain text for example purposes ONLY
    var password: String
    
    init(with map: Map) throws {
        _id = try ObjectId(try map.extract("_id"))
        username = try map.extract("username")
        age = try map.extract("age")
        password = try map.extract("password")
        metadata = ["special": true]
    }
}
```

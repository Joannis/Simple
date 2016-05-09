# Simple

A library that makes it very simple to set up a backend using MongoDB, Vapor (HTTP) routing and Models using Genome.

## Simple example 

```swift
import Simple

let app = try! SimpleApplication(databaseUrl: "mongodb://127.0.0.1:27017", database: "simple")

struct User: Model {
    static let collection = app.collection("users")
    let id: ObjectId
    let username: String
    let age: Int
    
    func serialize() throws -> Document {
        return [
                   "_id": ~id,
                   "username": ~username,
                   "age": ~age
        ]
    }
    
    init(with map: Map) throws {
        id = try ObjectId(try map.extract("_id"))
        username = try map.extract("username")
        age = try map.extract("age")
    }
    
    func sequence(_ map: Map) throws {
        try id.hexString ~> map["_id"]
        try username ~> map["username"]
        try age ~> map["age"]
    }
}

app.get("user", User.self) { request, user in
    return try user.toJson().serialize()
}

app.start(port: 8080)
```

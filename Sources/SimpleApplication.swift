import Vapor
import MongoKitten

public class SimpleApplication: Application {
    private let mongoServer: MongoKitten.Server
    private let database: MongoKitten.Database
    
    public required init(databaseUrl: String, database: String, sessionDriver: SessionDriver? = nil) throws {
        self.mongoServer = try MongoKitten.Server(databaseUrl, automatically: true)
        self.database = mongoServer[database]
        
        super.init(sessionDriver: sessionDriver)
    }
    
    public func collection(_ name: String) -> MongoKitten.Collection {
        return database[name]
    }
    
    public func get<RI: RequestInitializable>(_ path: String, handler: (RI) throws -> ResponseRepresentable) {
        self.get(path) { request in
            return try handler(RI(request: request))
        }
    }
    
    public func post<RI: RequestInitializable>(_ path: String, handler: (RI) throws -> ResponseRepresentable) {
        self.post(path) { request in
            return try handler(RI(request: request))
        }
    }
    
    public func put<RI: RequestInitializable>(_ path: String, handler: (RI) throws -> ResponseRepresentable) {
        self.put(path) { request in
            return try handler(RI(request: request))
        }
    }
    
    public func delete<RI: RequestInitializable>(_ path: String, handler: (RI) throws -> ResponseRepresentable) {
        self.delete(path) { request in
            return try handler(RI(request: request))
        }
    }
}
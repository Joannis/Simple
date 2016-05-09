import Vapor
import GenomeJson
@_exported import MongoKitten

public protocol Model: StringInitializable, MappableObject {
    static var collection: MongoKitten.Collection { get }
    var id: ObjectId { get }
    
    func store() throws
    static func find(matching query: MongoKitten.Query) throws -> Cursor<Self>
    static func findOne(matching query: MongoKitten.Query) throws -> Self?
    func remove() throws
    func serialize() throws -> Document
}

extension Model {
    public init?(from string: String) throws {
        guard let me = try Self.findOne(matching: "_id" == ObjectId(string)) else {
            return nil
        }
        
        self = me
    }
}

extension Model {
    public func store() throws {
        try Self.collection.update(matching: "_id" == id, to: try self.serialize())
    }
    
    public static func find(matching query: MongoKitten.Query) throws -> Cursor<Self> {
        let cursor = try Self.collection.find(matching: query)
        
        return Cursor(base: cursor) { input in
            return try? Self(node: ~input)
        }
    }
    
    public static func findOne(matching query: MongoKitten.Query) throws -> Self? {
        guard let result = try Self.collection.findOne(matching: query) else {
            return nil
        }
        
        return try? Self(node: ~result)
    }
    
    public func remove() throws {
        try Self.collection.remove(matching: "_id" == id)
    }
}
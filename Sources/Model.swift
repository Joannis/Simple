@_exported import Vapor
@_exported import GenomeJson
@_exported import MongoKitten
import Reflection

public protocol Model: StringInitializable, MappableObject, Genome.NodeConvertible, ResponseRepresentable {
    static var collection: MongoKitten.Collection { get }
    var _id: ObjectId { get set }
    var metadata: Document { get set }
    
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
    
    public func makeResponse() -> Response {
        if let node = try? toData(type: GenomeJson.Json) {
            return node.serialize().makeResponse()
        }
        
        return Response(error: "Internal server error")
    }
    
    public func store() throws {
        let doc = try serialize()
        
        let upsert: Document = ["$set": ~doc]
        
        try Self.collection.update(matching: "_id" == _id, to: upsert, upserting: true)
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
        try Self.collection.remove(matching: "_id" == _id)
    }
    
    public func sequence(_ map: Map) throws {
        let doc = try serialize()
        
        for (k, v) in doc {
            try v ~> map[k]
        }
    }
}

public protocol ReflectableModel: Model { }

extension ReflectableModel {
    typealias GNode = Genome.Node
    
    public func serialize() throws -> Document {
        let properties = try Reflection.properties(self)
        var doc: Document = [:]
        
        for property in properties where property.key != "metadata" {
            if let p = property.value as? ValueConvertible {
                doc[property.key] = p.makeBsonValue()
            }
        }
        
        for (k, v) in metadata where doc[k] == .nothing {
            doc[k] = v
        }
        
        return doc
    }
    
    public func toNode() throws -> Genome.Node {
        var dict = [String: GNode]()
        
        let properties = try Reflection.properties(self)
        
        for property in properties where property.key != "metadata" {
            if let p = property.value as? Genome.NodeConvertible {
                dict[property.key] = try p.toNode()
            }
        }
        
        for (k, v) in metadata where dict[k] == nil {
            dict[k] = try v.toNode()
        }
        
        return Genome.Node.object(dict)
    }
}
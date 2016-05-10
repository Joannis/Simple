import Vapor
import Genome

extension Vapor.Json: Genome.NodeConvertible {
    public typealias GNode = Genome.Node
    
    public func toNode() throws -> GNode {
        switch self {
        case .array(let nodes):
            let values = try nodes.map { try $0.toNode() }
            return .array(values)
        case .bool(let b):
            return .bool(b)
        case .double(let d):
            return .number(d)
        case .string(let s):
            return .string(s)
        case .object(let map):
            var json = [String: GNode]()
            
            for (k, v) in map {
                json[k] = try v.toNode()
            }
            
            return .object(json)
        default:
            return .null
        }
    }
}

extension Genome.Node: Vapor.JsonRepresentable {
    public typealias VJson = Vapor.Json
    public func makeJson() -> VJson {
        switch self {
        case .array(let nodes):
            let values = nodes.map { $0.makeJson() }
            return .array(values)
        case .bool(let b):
            return .bool(b)
        case .number(let d):
            return .double(d)
        case .string(let s):
            return .string(s)
        case .object(let map):
            var json = [String: VJson]()
            
            for (k, v) in map {
                json[k] = v.makeJson()
            }
            
            return .object(json)
        default:
            return .null
        }
    }
}
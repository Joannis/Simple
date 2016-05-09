import MongoKitten
import Genome
import CryptoEssentials

extension Genome.Node: BSON.ValueConvertible {
    typealias BSONValue = BSON.Value
    
    public func makeBsonValue() -> BSON.Value {
        switch self {
        case .array(let nodes):
            let values = nodes.map { $0.makeBsonValue() }
            return ~Document(array: values)
        case .bool(let b):
            return ~b
        case .number(let d):
            return ~d
        case .string(let s):
            return ~s
        case .object(let map):
            var doc: Document = []
            
            for (k, v) in map {
                doc[k] = v.makeBsonValue()
            }
            
            return ~doc
        default:
            return .null
        }
    }
}

extension BSON.Value: NodeConvertible {
    typealias GNode = Genome.Node
    
    public init(with node: Genome.Node, in context: Context) throws {
        self = node.makeBsonValue()
    }
    
    public func toNode() throws -> Genome.Node {
        switch self {
        case .array(let arr):
            let array = try arr.arrayValue.map { try $0.toNode() }
            return GNode.array(array)
        case .binary(_, let data):
            return GNode.string(data.hexString)
        case .boolean(let bool):
            return GNode.bool(bool)
        case .double(let double):
            return GNode.number(double)
        case .int32(let int):
            return GNode.number(Double(int))
        case .int64(let int):
            return GNode.number(Double(int))
        case .document(let doc):
            var object = [String: GNode]()
            
            for (k, v) in doc.dictionaryValue {
                object[k] = try v.toNode()
            }
            
            return GNode.object(object)
        case .dateTime(let date):
            return GNode.number(Double(date.timeIntervalSince1970))
        case .javascriptCode(let code):
            return GNode.string(code)
        case .javascriptCodeWithScope(let code, _):
            return GNode.string(code)
        case .objectId(let oid):
            return GNode.string(oid.hexString)
        case .regularExpression(let pattern, _):
            return GNode.string(pattern)
        case .timestamp(let timestamp):
            return GNode.number(Double(timestamp))
        case .string(let s):
            return GNode.string(s)
        default:
            return GNode.null
        }
    }
}
import Vapor

public protocol RequestInitializable {
    var request: Request { get }
    
    init(request: Request) throws
}
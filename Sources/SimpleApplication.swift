//
//  SimpleApplication.swift
//  SimplyAwesome
//
//  Created by Joannis Orlandos on 09/05/16.
//
//

import Vapor
import MongoKitten

public class SimpleApplication: Application {
    public let mongoServer: MongoKitten.Server
    public let database: MongoKitten.Database
    
    public required init(databaseUrl: String, database: String, sessionDriver: SessionDriver? = nil) throws {
        self.mongoServer = try MongoKitten.Server(databaseUrl, automatically: true)
        self.database = mongoServer[database]
        
        super.init(sessionDriver: sessionDriver)
    }
    
    public func collection(_ name: String) -> MongoKitten.Collection {
        return database[name]
    }
}
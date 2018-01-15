//
//  Prediction.swift
//  KreskinPackageDescription
//
//  Created by Michael Critz on 1/14/18.
//

import Vapor
import FluentProvider
import HTTP

final class Prediction: Model {
    let storage = Storage()
    
    var title: String
    var description: String
    
    init(title: String, description: String) {
        self.title = title
        self.description = description
    }
    
    init(row: Row) throws {
        title = try row.get("title")
        description = try row.get("description")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("description", description)
        return row
    }
}

extension Prediction: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("title")
            builder.string("description")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Prediction: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            title: json.get("title"),
            description: json.get("description")
        )
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        try json.set("descriotion", description)
        if let updatedAt: Date = self.updatedAt {
            try json.set("updatedAt", updatedAt)
        }
        if let createdAt: Date = self.createdAt {
            try json.set("createdAt", createdAt)
        }
        return json
    }
}

extension Prediction: ResponseRepresentable { }
extension Prediction: Timestampable { }










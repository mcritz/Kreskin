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
    var premise: String
    var description: String
    var isRevealed: Bool
    
    
    init(title: String, premise: String, description: String, isRevealed: Bool? = false) {
        self.title = title
        self.premise = premise
        self.description = description
        if let isRevealed: Bool = isRevealed {
            self.isRevealed = isRevealed
        } else {
            self.isRevealed = false
        }
    }
    
    init(row: Row) throws {
        title = try row.get("title")
        premise = try row.get("premise")
        description = try row.get("description")
        isRevealed = try row.get("isRevealed")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("premise", premise)
        try row.set("description", description)
        try row.set("isRevealed", isRevealed)
        return row
    }
}

extension Prediction: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("title")
            builder.string("premise")
            builder.string("description")
            builder.bool("isRevealed")
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
            premise: json.get("premise"),
            description: json.get("description"),
            isRevealed: false
        )
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        try json.set("premise", premise)
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










//
//  Topic.swift
//  KreskinPackageDescription
//
//  Created by Critz, Michael on 3/17/18.
//

import Vapor
import FluentProvider
import HTTP

final class Topic: Model {
    let storage = Storage()
    
    let title: String
    let userId: Int
    
    init(title: String, userId: Int) {
        self.title = title
        self.userId = userId
    }
    
    init(row: Row) throws {
        title = try row.get("title")
        userId = try row.get("user_id")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("user_id", userId)
        return row
    }
}

// MARK: Relations & Representation
extension Topic {
    var predictions: Children<Topic, Prediction> {
        return children()
    }
}

extension Topic: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("title")
            builder.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Topic: JSONConvertible {
    convenience init(json: JSON) throws {
        let userId: Int = try json.get("userId")
        try self.init(
            title: json.get("title"),
            userId: userId
        )
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        if let updatedAt: Date = self.updatedAt {
            try json.set("updatedAt", updatedAt)
        }
        if let createdAt: Date = self.createdAt {
            try json.set("createdAt", createdAt)
        }
        try json.set("userId", userId)
        return json
    }
}

extension Topic: ResponseRepresentable { }
extension Topic: NodeRepresentable { }
extension Topic: Timestampable { }


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
    var topicId: Int
    var userId: Int
    
    
    init(title: String, premise: String, description: String, isRevealed: Bool? = false, userId: Int, topicId: Int) {
        self.title = title
        self.premise = premise
        self.description = description
        if let isRevealed: Bool = isRevealed {
            self.isRevealed = isRevealed
        } else {
            self.isRevealed = false
        }
        self.userId = userId
        self.topicId = topicId
    }
    
    init(row: Row) throws {
        title = try row.get("title")
        premise = try row.get("premise")
        description = try row.get("description")
        isRevealed = try row.get("isRevealed")
        userId = try row.get("user_id")
        topicId = try row.get("topic_id")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("title", title)
        try row.set("premise", premise)
        try row.set("description", description)
        try row.set("isRevealed", isRevealed)
        try row.set("user_id", userId)
        try row.set("topic_id", topicId)
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
            builder.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Prediction: JSONConvertible {
    convenience init(json: JSON) throws {
        let userId: Int = try json.get("userId")
        try self.init(
            title: json.get("title"),
            premise: json.get("premise"),
            description: json.get("description"),
            isRevealed: false,
            userId: userId,
            topicId: json.get("topicId")
        )
    }
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("title", title)
        try json.set("premise", premise)
        try json.set("isRevealed", isRevealed)
        try json.set("description", description)
        if let updatedAt: Date = self.updatedAt {
            try json.set("updatedAt", updatedAt)
        }
        if let createdAt: Date = self.createdAt {
            try json.set("createdAt", createdAt)
        }
        try json.set("userId", userId)
        try json.set("topicId", topicId)
        return json
    }
}

extension Prediction: ResponseRepresentable { }
extension Prediction: NodeRepresentable { }
extension Prediction: Timestampable { }


final class PredixTopicFKeyMigration: Preparation {
    static func prepare(_ database: Database) throws {
        do {
            try database.modify(Prediction.self) { builder in
                print("MODIFY: Add TopicId FKey to Prediction")
                builder.foreignId(for: Topic.self)
            }
        } catch {
            print("ONOESZ! Failed Migration for Prediction TopicID FKey")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(User.self)
    }
}









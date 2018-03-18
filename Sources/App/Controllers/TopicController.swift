//
//  TopicController.swift
//  KreskinPackageDescription
//
//  Created by Critz, Michael on 3/17/18.
//

import Vapor

final class TopicController {
    func index(_ req: Request) throws -> ResponseRepresentable {
        let topix = try Topic.makeQuery().all()
        return try topix.makeJSON()
    }
    
    func create(_ req: Request) throws -> ResponseRepresentable {
        guard var json = req.json else {
            throw Abort(.badRequest)
        }
        var topic: Topic
        do {
            let user = try req.user()
            try json.set("userId", user.id)
            topic = try Topic(json: json)
            try topic.save()
        } catch {
            throw Abort(.internalServerError)
        }
        return topic
    }
    
    func get(_ req: Request) throws -> ResponseRepresentable {
        guard let idd: Int = req.parameters["id"]?.int else {
            throw Abort(.badRequest)
        }
        if let topic = try Topic.find(idd) {
            return try topic.makeJSON()
        }
        throw Abort(.internalServerError)
    }
    
    func delete(_ req: Request) throws -> ResponseRepresentable {
        guard let idx: Int = req.parameters["id"]?.int else {
            throw Abort(.badRequest)
        }
        let user = try req.user()
        if let topic = try Topic.find(idx) {
            if topic.userId == user.id?.int {
                try topic.delete()
            } else {
                throw Abort(.unauthorized)
            }
        }
        throw Abort(.notFound, reason: "Topic \(idx) does not exist")
    }
}

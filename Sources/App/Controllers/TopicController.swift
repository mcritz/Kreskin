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
}

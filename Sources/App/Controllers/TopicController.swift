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
}

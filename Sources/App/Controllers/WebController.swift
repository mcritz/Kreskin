//
//  WebController.swift
//  Kreskin
//
//  Created by Michael Critz on 1/28/18.
//

import Vapor

final class WebController {
    let viewRenderer: ViewRenderer
    init(renderer: ViewRenderer) {
        self.viewRenderer = renderer
    }
    func indexHandler(_ req: Request) throws -> ResponseRepresentable {
        var parameters: [String: NodeRepresentable] = [:]
        do {
            let user = try req.user()
            parameters["name"] = user.name
        } catch {
            parameters["name"] = "Faceless Drone"
        }
        return try viewRenderer.make("index", parameters)
    }
}

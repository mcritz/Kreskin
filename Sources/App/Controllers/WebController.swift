//
//  WebController.swift
//  Kreskin
//
//  Created by Michael Critz on 1/28/18.
//

import Vapor

final class WebController {
    let viewRenderer: ViewRenderer
    let predixController = PredictionController()
    
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
        do {
            let predix = try predixController.index(req)
            parameters["predictions"] = predix as? NodeRepresentable
        } catch {
            throw Abort(.internalServerError)
        }
        return try viewRenderer.make("index", parameters)
    }
}

//
//  PredictionController.swift
//  KreskinPackageDescription
//
//  Created by Critz, Michael on 1/19/18.
//

import Vapor

final class PredictionController {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        let maybePredictions = try preditions(user: nil)?.makeJSON()
        guard let predix: JSON = maybePredictions else { throw Abort(.internalServerError) }
        return predix
    }
    
    func create(_ req: Request) throws -> ResponseRepresentable {
        guard var json = req.json else {
            throw Abort(.badRequest)
        }
        var prediction: Prediction
        do {
            let user = try req.user()
            let userId = user.id
            try json.set("userId", userId)
            prediction = try Prediction(json: json)
            try prediction.save()
        } catch {
            throw Abort(.internalServerError)
        }
        return prediction
    }
    
    func get(_ req: Request) throws -> ResponseRepresentable {
        guard let idx: Int = req.parameters["id"]?.int else {
            throw Abort(.badRequest)
        }
        guard let prediction: Prediction = try Prediction.find(idx) else {
            throw Abort(.notFound)
        }
        if (!prediction.isRevealed) {
            prediction.description = "—"
        }
        return prediction
    }
    
    func update(_ req: Request) throws -> ResponseRepresentable {
        guard let json: JSON = req.json else {
            throw Abort(.badRequest)
        }
        guard let idx: Int = req.parameters["id"]?.int else {
            throw Abort(.badRequest)
        }
        guard let predix: Prediction = try Prediction.find(idx) else {
            throw Abort(.notFound)
        }
        
        let user = try req.user()
        guard let userId: Int = user.id?.int else {
            throw Abort(.internalServerError)
        }
        if userId != predix.userId {
            throw Abort(.unauthorized)
        }
        if let isRevealed: Bool = json["isRevealed"]?.bool {
            predix.isRevealed = isRevealed
        }
        if let title: String = json["title"]?.string {
            predix.title = title
        }
        if let premise: String = json["premise"]?.string {
            predix.premise = premise
        }
        if let description: String = json["description"]?.string {
            predix.description = description
        }
        do {
            try predix.save()
        } catch {
            throw Abort(.internalServerError)
        }
        if !(predix.isRevealed) {
            predix.description = "–"
        }
        return predix
    }
    
    func preditions(user: User?) throws -> [Prediction]? {
        var maybePredictions: [Prediction]?
        if let realUser: User = user {
            do {
                maybePredictions = try realUser.predictions.all()
            } catch {
                throw Abort(.internalServerError)
            }
        } else {
            do {
                maybePredictions = try Prediction.makeQuery().all()
            } catch {
                throw Abort(.internalServerError)
            }
        }
        guard var predix: [Prediction] = maybePredictions else {
            throw Abort(.internalServerError)
        }
        // mask for un-revealed Prediction
        predix = predix.map{ prediction in
            if !prediction.isRevealed {
                prediction.description = "–"
            }
            return prediction
        }
        
        // sort by createdAt
        predix.sort(by: { (A, B) -> Bool in
            if let aCreatedDate: Date = A.createdAt,
                let bCreatedDate: Date = B.createdAt {
                return aCreatedDate < bCreatedDate
            }
            return false
        })
        return predix
    }
}

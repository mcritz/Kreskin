//
//  PredictionController.swift
//  KreskinPackageDescription
//
//  Created by Critz, Michael on 1/19/18.
//

import Vapor

class PredictionController {
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

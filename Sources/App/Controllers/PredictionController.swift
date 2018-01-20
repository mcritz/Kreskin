//
//  PredictionController.swift
//  KreskinPackageDescription
//
//  Created by Critz, Michael on 1/19/18.
//

import Vapor

class PredictionController {
    func preditions(user: User?) -> [Prediction]? {
        var predix: [Prediction]
        if let realUser: User = user {
            predix = try user.predictions.all()
        } else {
            predix = try predictions.makeQuery().all()
        }
        
        // mask for un-revealed Prediction
        predix = predix.map{
            if !$0.isRevealed {
                $0.description = "–"
            }
            return $0
        }
        
        // sort by createdAt
        predix.sort(by: { (A, B) -> Bool in
            if let aCreatedDate: Date = A.createdAt,
                let bCreatedDate: Date = B.createdAt {
                return aCreatedDate < bCreatedDate
            }
            return false
        })
    }
}

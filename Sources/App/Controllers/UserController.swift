//
//  UserController.swift
//  App
//
//  Created by Michael Critz on 1/21/18.
//

import Foundation
import Vapor

final class UserController {
    
    let predixController = PredictionController()
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        var users = try User.makeQuery().all()
        users = users.map{ user in
            user.email = ""
            user.password = nil
            return user
        }
        let usersJSON = try users.makeJSON()
        return usersJSON
    }
    
    func predictionsForUser(with req: Request) throws -> ResponseRepresentable {
        let maybeId = req.parameters["id"]?.int
        guard let idx: Int = maybeId else {
            throw Abort(.badRequest)
        }
        guard let user = try User.find(idx) else {
            throw Abort(.notFound)
        }
        guard let predix = try predixController.preditions(user: user) else {
            throw Abort(.internalServerError)
        }
        var responseJSON = JSON()
        try responseJSON.set("predictions", predix)
        return responseJSON
    }
    
    func isValid(email testString: String?) -> Bool {
        guard let realString: String = testString else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: realString)
    }
    func isValid(name testString: String?) -> Bool {
        guard let realString: String = testString else { return false }
        return realString.count >= 3 ? true : false
    }
    func isValid(password testString: String?) -> Bool {
        guard let realString: String = testString else { return false }
        let passwordRegex = "^(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegex)
        return passwordTest.evaluate(with: realString)
    }
}

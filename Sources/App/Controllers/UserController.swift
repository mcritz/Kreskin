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
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
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
    func isValid(email testString: String) -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: testString, options: [], range: NSRange(location: 0, length: testString.characters.count)) != nil
    }

    func isValid(name testString: String?) -> Bool {
        guard let realString: String = testString else { return false }
        return realString.characters.count >= 3 ? true : false
    }
    func isValid(password testString: String?) -> Bool {
        guard let realString: String = testString else { return false }
        let passwordRegex = try! NSRegularExpression(pattern: "^(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$", options: .caseInsensitive)
        let passwordMatch = passwordRegex.firstMatch(in: realString, options: [], range: NSRange(location: 0, length: realString.characters.count))
        return passwordMatch != nil
    }
}

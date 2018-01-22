//
//  UserController.swift
//  App
//
//  Created by Michael Critz on 1/21/18.
//

import Foundation

class UserController {
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

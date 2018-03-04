import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
        try setupUnauthenticatedRoutes()
        try setupPasswordProtectedRoutes()
        try setupTokenProtectedRoutes()
    }

    /// Sets up all routes that can be accessed
    /// without any authentication. This includes
    /// creating a new User.
    private func setupUnauthenticatedRoutes() throws {
        
        let predixController = PredictionController()
        let userController = UserController()
        let webController = WebController(renderer: view)

        get("/") { req in
            return try webController.indexHandler(req)
        }
        get("/healthcheck") { req in
            throw Abort(.ok)
        }
        get("index") { req in
            return try webController.indexHandler(req)
        }
        get("index.html") { req in
            return try webController.indexHandler(req)
        }
        // a simple json example response
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        // create a new user
        //
        // POST /users
        // <json containing new user information>
        post("users") { req in
            // require that the request body be json
            guard let json = req.json else {
                throw Abort(.badRequest, reason: "User creation requires a user in JSON format")
            }

            // initialize the name and email from
            // the request json
            let user = try User(json: json)

            // ensure no user with this email already exists
            guard try User.makeQuery().filter("email", user.email).first() == nil else {
                throw Abort(.badRequest, reason: "A user with that email already exists.")
            }

            // require a plaintext password is supplied
            guard let password = json["password"]?.string else {
                throw Abort(.badRequest)
            }

            // hash the password and set it on the user
            /**
             *
             *  !!! IMPORTANT !!!
             *  Expectation is the user of the Bcrypt hasher
             *  1. Config/droplet.json must have hash set to bcrypt
             *  2. Config/production/bcrypt.json should have the cost set to 12+
             * 
             **/
            user.password = try self.hash.make(password.makeBytes()).makeString()

            // save and return the new user
            try user.save()
            return user
        }
        
        get("predictions", ":id") { req in
            let prediction = try predixController.get(req)
            return prediction
        }
        
        get("predictions") { req in
            let predix = try predixController.index(req)
            return predix
        }
        
        get("users") { req in
            let users = try userController.index(req)
            return users
        }
        
        get("users", ":id", "predictions") { req in
            let userPredix = try userController.predictionsForUser(with: req)
            return userPredix
        }
        
        post("logout") { req in
            try req.auth.unauthenticate()
            return "bye"
        }
    }

    /// Sets up all routes that can be accessed using
    /// username + password authentication.
    /// Since we want to minimize how often the username + password
    /// is sent, we will only use this form of authentication to
    /// log the user in.
    /// After the user is logged in, they will receive a token that
    /// they can use for further authentication.
    private func setupPasswordProtectedRoutes() throws {
        // creates a route group protected by the password middleware.
        // the User type can be passed to this middleware since it
        // conforms to PasswordAuthenticatable
        let password = grouped([
            PasswordAuthenticationMiddleware(User.self)
        ])

        // verifies the user has been authenticated using the password
        // middleware, then generates, saves, and returns a new access token.
        //
        // POST /login
        // Authorization: Basic <base64 email:password>
        password.post("login") { req in
            let user = try req.user()
            let token = try Token.generate(for: user)
            try token.save()
            var response = try token.makeJSON()
            if let userID: Int = user.id?.int {
                try response.set("user_id", userID)
            }
            try response.set("user", user)
            return response
        }
    }

    /// Sets up all routes that can be accessed using
    /// the authentication token received during login.
    /// All of our secure routes will go here.
    private func setupTokenProtectedRoutes() throws {
        let predixController = PredictionController()

        // creates a route group protected by the token middleware.
        // the User type can be passed to this middleware since it
        // conforms to TokenAuthenticatable
        let token = grouped([
            TokenAuthenticationMiddleware(User.self)
        ])

        // simply returns a greeting to the user that has been authed
        // using the token middleware.
        //
        // GET /me
        // Authorization: Bearer <token from /login>
        token.get("me") { req in
            let user = try req.user()
            return "Hello, \(user.name)"
        }
        
        token.delete("predictions", ":id") { req in
            let predix = try predixController.delete(req)
            return predix
        }
        
        token.put("predictions", ":id") { req in
            let predix = try predixController.update(req)
            return predix
        }
        
        token.post("predictions") { req in
            let prediction = try predixController.create(req)
            return prediction
        }
    }
}

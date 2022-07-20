{{#fluent}}import Fluent
{{/fluent}}import Vapor

func routes(_ app: Application) throws {
    {{#leaf}}app.get { req async throws in
        return try await req.view.render("index", ["title": "Hello Vapor!"])
    }{{/leaf}}{{^leaf}}app.get { req async in
        return "It works!"
    }{{/leaf}}

    app.get("hello") { req async -> String in
        return "Hello, world!"
    }{{#fluent}}

    try app.register(collection: TodoController()){{/fluent}}
}

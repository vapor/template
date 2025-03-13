{{#fluent}}import Fluent
{{/fluent}}import Vapor

func routes(_ app: Application) throws {
    {{#leaf}}app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }{{/leaf}}{{^leaf}}app.get { req async in
        "It works!"
    }{{/leaf}}

    app.get("hello") { req async -> String in
        "Hello, world!"
    }{{#fluent}}

    try app.register(collection: TodoController()){{/fluent}}
}

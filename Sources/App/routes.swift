{{#fluent}}import FluentKit
{{/fluent}}import RoutingKit
import Vapor

func routes(_ app: Application{{#fluent}}, database: any Database{{/fluent}}) async throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }{{#fluent}}

    try await app.register(collection: TodoController(database: database)){{/fluent}}
}

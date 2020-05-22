{{#fluent}}import Fluent
{{/fluent}}import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }{{#fluent}}

    try app.register(collection: TodoController()){{/fluent}}
}

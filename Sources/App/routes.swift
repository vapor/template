{{#fluent}}import Fluent
{{/fluent}}import Vapor

func routes(_ app: Application) throws {
    {{#leaf}}app.get { req in
        return req.view.render("index", ["title": "Hello Vapor!"])
    }{{/leaf}}{{^leaf}}app.get { req in
        return "It works!"
    }{{/leaf}}

    app.get("hello") { req -> String in
        eturn "Hello, world!"
    }{{#fluent}}

    try app.register(collection: TodoController()){{/fluent}}
}

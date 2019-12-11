{{#fluent}}import Fluent
import Fluent{{fluent.db.module}}Driver
{{/fluent}}import Vapor

// configures your application
func configure(_ app: Application) {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)){{#fluent}}

    {{#fluent.db.is_postgres}}try app.databases.use(.postgres(
        hostname: "localhost",
        username: "vapor",
        password: "vapor",
        database: "vapor"
    ), as: .psql){{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}try app.databases.use(.mysql(
        hostname: "localhost",
        username: "vapor",
        password: "vapor",
        database: "vapor"
    ), as: .mysql){{/fluent.db.is_mysql}}{{#fluent.db.is_sqlite}}try app.databases.use(.sqlite(
        file: "db.sqlite"
    ), as: .sqlite){{/fluent.db.is_sqlite}}

    app.migrations.add(CreateTodo()){{/fluent}}

    // register routes
    try routes(app)
}

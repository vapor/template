{{#fluent}}import Fluent
import Fluent{{fluent.db.module}}Driver
{{/fluent}}import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)){{#fluent}}

    {{#fluent.db.is_postgres}}app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .psql){{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}app.databases.use(.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database"
    ), as: .mysql){{/fluent.db.is_mysql}}{{#fluent.db.is_mongo}}try app.databases.use(.mongo(
        connectionString: Environment.get("DATABASE_URL") ?? "mongodb://localhost:27017/vapor_database"
    ), as: .mongo){{/fluent.db.is_mongo}}{{#fluent.db.is_sqlite}}app.databases.use(.sqlite(.file("db.sqlite")), as: .sqlite){{/fluent.db.is_sqlite}}

    app.migrations.add(CreateTodo()){{/fluent}}

    // register routes
    try routes(app)
}

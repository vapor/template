{{#fluent}}import Fluent
import Fluent{{fluent.db.module}}Driver
{{/fluent}}import Vapor

// configures your application
func configure(_ app: Application) {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)){{#fluent}}

{{#fluent.db.is_postgres}}
    try app.databases.use(.postgres(url: "postgres://vapor:vapor@localhost:5432/vapor"), as: .psql){{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}
    try app.databases.use(.mysql(url: "mysql://vapor:vapor@localhost:3306/vapor"), as: .mysql){{/fluent.db.is_mysql}}{{#fluent.db.is_sqlite}}
    try app.databases.use(.sqlite(file: "db.sqlite"), as: .sqlite){{/fluent.db.is_sqlite}}

    app.migrations.add(CreateTodo()){{/fluent}}

    // register routes
    try routes(app)
}

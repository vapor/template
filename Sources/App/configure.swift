{{#fluent}}import Configuration
import NIOSSL
import FluentKit
import Fluent{{fluent.db.module}}Driver
{{/fluent}}import Vapor

/// configures your application
func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory)){{#fluent}}

    let databases = Databases(threadPool: .singleton, on: .singletonMultiThreadedEventLoopGroup)

    {{#fluent.db.is_postgres}}let databaseConfig = app.configReader.scoped(to: "database")

    databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
        hostname: databaseConfig.string(forKey: "host", default: "localhost"),
        port: databaseConfig.int(forKey: "port", default: SQLPostgresConfiguration.ianaPortNumber),
        username: databaseConfig.string(forKey: "username", default: "vapor_username"),
        password: databaseConfig.string(forKey: "password", default: "vapor_password"),
        database: databaseConfig.string(forKey: "name", default: "vapor_database"),
        tls: .prefer(try .init(configuration: .clientDefault)))
    ), as: .psql){{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}let databaseConfig = app.configReader.scoped(to: "database")

    databases.use(DatabaseConfigurationFactory.mysql(
        hostname: databaseConfig.string(forKey: "host", default: "localhost"),
        port: databaseConfig.int(forKey: "port", default: MySQLConfiguration.ianaPortNumber),
        username: databaseConfig.string(forKey: "username", default: "vapor_username"),
        password: databaseConfig.string(forKey: "password", default: "vapor_password"),
        database: databaseConfig.string(forKey: "name", default: "vapor_database")
    ), as: .mysql){{/fluent.db.is_mysql}}{{#fluent.db.is_sqlite}}databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite){{/fluent.db.is_sqlite}}

    // close database connections cleanly on shutdown
    app.addService(databases)

    // run migrations before the app boots
    app.addLifecycleHandler(MigrateLifecycleHandler(databases: databases, migrations: CreateTodo())){{/fluent}}

    // register routes
    try await routes(app{{#fluent}}, databases: databases{{/fluent}})
}

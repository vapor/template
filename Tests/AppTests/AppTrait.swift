@testable import {{name}}
import Testing
import Vapor
{{#fluent}}import NIOSSL
import FluentKit
import Fluent{{fluent.db.module}}Driver
{{/fluent}}
@TaskLocal var _application: Application?

var app: Application {
    get throws { try #require(_application) }
}
{{#fluent}}
@TaskLocal var _database: (any Database)?

var database: any Database {
    get throws { try #require(_database) }
}
{{/fluent}}
struct AppTrait: TestTrait, SuiteTrait, TestScoping {
    func provideScope(
        for test: Test, testCase: Test.Case?, performing function: @Sendable @concurrent () async throws -> Void
    ) async throws {
        let app = try Application(.testing){{#fluent}}

        let databaseConfig = app.configReader.scoped(to: "database")

        let databases = Databases(threadPool: .singleton, on: .singletonMultiThreadedEventLoopGroup)
        {{#fluent.db.is_postgres}}databases.use(DatabaseConfigurationFactory.postgres(configuration: .init(
            hostname: databaseConfig.string(forKey: "host", default: "localhost"),
            port: databaseConfig.int(forKey: "port", default: SQLPostgresConfiguration.ianaPortNumber),
            username: databaseConfig.string(forKey: "username", default: "vapor_username"),
            password: databaseConfig.string(forKey: "password", default: "vapor_password"),
            database: databaseConfig.string(forKey: "name", default: "vapor_database"),
            tls: .prefer(try .init(configuration: .clientDefault)))
        ), as: .psql){{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}databases.use(DatabaseConfigurationFactory.mysql(
            hostname: databaseConfig.string(forKey: "host", default: "localhost"),
            port: databaseConfig.int(forKey: "port", default: MySQLConfiguration.ianaPortNumber),
            username: databaseConfig.string(forKey: "username", default: "vapor_username"),
            password: databaseConfig.string(forKey: "password", default: "vapor_password"),
            database: databaseConfig.string(forKey: "name", default: "vapor_database")
        ), as: .mysql){{/fluent.db.is_mysql}}{{#fluent.db.is_sqlite}}databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite){{/fluent.db.is_sqlite}}

        do {
            try await configure(app)
            try await app.run()
            try await $_database.withValue(databases.database(for: app)) {
                try await $_application.withValue(app) {
                    try await function()
                }
            }
            try await databases.revert(migrations: CreateTodo(), on: app)
            await databases.shutdownAsync()
        } catch {
            try? await databases.revert(migrations: CreateTodo(), on: app)
            await databases.shutdownAsync()
            try? await app.shutdown()
            throw error
        }{{/fluent}}{{^fluent}}
        do {
            try await configure(app)
            try await $_application.withValue(app) {
                try await function()
            }
        } catch {
            try? await app.shutdown()
            throw error
        }{{/fluent}}
        try await app.shutdown()
    }
}

extension Trait where Self == AppTrait {
    static func withApp() -> Self { .init() }
}

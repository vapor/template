{{#fluent}}import Configuration
import FluentKit
import Fluent{{fluent.db.module}}Driver
import NIOSSL
{{/fluent}}
import Testing
import Vapor
import VaporTesting

@testable import {{name}}

@TaskLocal var _application: Application?
{{#fluent}}
@TaskLocal var _database: (any Database)?
{{/fluent}}

struct AppTrait: TestTrait, SuiteTrait, TestScoping {
    var isRecursive: Bool { true }

    func provideScope(
        for test: Test, testCase: Test.Case?, performing function: @Sendable @concurrent () async throws -> Void
    ) async throws {
        {{#fluent}}try await VaporTesting::withApp { application in
            let databases = Databases(threadPool: .singleton, on: .singletonMultiThreadedEventLoopGroup)
            {{#fluent.db.is_postgres}}let databaseConfig = application.configReader.scoped(to: "database")
            databases.use(
                DatabaseConfigurationFactory.postgres(
                    configuration: .init(
                        hostname: databaseConfig.string(forKey: "host", default: "localhost", isSecret: true),
                        port: databaseConfig.int(forKey: "port", default: SQLPostgresConfiguration.ianaPortNumber, isSecret: true),
                        username: databaseConfig.string(forKey: "username", default: "vapor_username", isSecret: true),
                        password: databaseConfig.string(forKey: "password", default: "vapor_password", isSecret: true),
                        database: databaseConfig.string(forKey: "name", default: "vapor_database", isSecret: true),
                        tls: .prefer(try .init(configuration: .clientDefault))
                    )
                ),
                as: .psql
            ){{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}let databaseConfig = application.configReader.scoped(to: "database")
            databases.use(
                DatabaseConfigurationFactory.mysql(
                    hostname: databaseConfig.string(forKey: "host", default: "localhost", isSecret: true),
                    port: databaseConfig.int(forKey: "port", default: MySQLConfiguration.ianaPortNumber, isSecret: true),
                    username: databaseConfig.string(forKey: "username", default: "vapor_username", isSecret: true),
                    password: databaseConfig.string(forKey: "password", default: "vapor_password", isSecret: true),
                    database: databaseConfig.string(forKey: "name", default: "vapor_database", isSecret: true)
                ),
                as: .mysql
            ){{/fluent.db.is_mysql}}{{#fluent.db.is_sqlite}}databases.use(DatabaseConfigurationFactory.sqlite(.file("db.sqlite")), as: .sqlite){{/fluent.db.is_sqlite}}
            application.addLifecycleHandler(MigrateLifecycleHandler(databases: databases, migrations: CreateTodo()))

            try await routes(application, databases: databases)

            try await $_database.withValue(databases.database()) {
                try await $_application.withValue(application) {
                    do {
                        try await application.boot()
                        try await function()
                        try await databases.revert(migrations: CreateTodo(), on: application)
                        await databases.shutdownAsync()
                    } catch {
                        try? await databases.revert(migrations: CreateTodo(), on: application)
                        await databases.shutdownAsync()
                        throw error
                    }
                }
            }
        }{{/fluent}}{{^fluent}}try await VaporTesting::withApp(configure: configure) { application in
            try await $_application.withValue(application) {
                try await function()
            }
        }{{/fluent}}
    }
}

extension Trait where Self == AppTrait {
    /// Enable this trait to access a fresh instance of your Vapor application for each test at the `app` variable.{{#fluent}}
    /// You will also have access to your database at the `database` variable, with migrations run before and reverted after each test.{{/fluent}}
    static var withApp: Self { .init() }
}

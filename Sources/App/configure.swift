{{#fluent}}import Fluent
import Fluent{{fluent.db.module}}Driver
{{/fluent}}import Vapor

/// Called before your application initializes.
func configure(_ s: inout Services) {
    {{#fluent}}/// Register providers first
    s.provider(FluentProvider())

    {{/fluent}}/// Register routes
    s.extend(Routes.self) { r, c in
        try routes(r, c)
    }

    /// Register middleware
    s.register(MiddlewareConfiguration.self) { c in
        // Create _empty_ middleware config
        var middlewares = MiddlewareConfiguration()
        
        // Serves files from `Public/` directory
        /// middlewares.use(FileMiddleware.self)
        
        // Catches errors and converts to HTTP response
        try middlewares.use(c.make(ErrorMiddleware.self))
        
        return middlewares
    }{{#fluent}}

    s.register(Database.self) { c in
        return try c.make(Databases.self).database(.{{fluent.db.id}})!
    }{{#fluent.db.is_postgres}}

    s.extend(Databases.self) { dbs, c in
        try dbs.postgres(config: c.make())
    }

    s.register(PostgresConfiguration.self) { c in
        return .init(hostname: "vapor", username: "vapor", password: "vapor")
    }
    {{/fluent.db.is_postgres}}{{#fluent.db.is_mysql}}

    s.extend(Databases.self) { dbs, c in
        try dbs.mysql(configuration: c.make())
    }

    s.register(MySQLConfiguration.self) { c in
        return .init(hostname: "vapor", username: "vapor", password: "vapor")
    }
    {{/fluent.db.is_mysql}}{{#fluent.db.is_sqlite}}

    s.extend(Databases.self) { dbs, c in
        try dbs.sqlite(configuration: c.make(), threadPool: c.make())
    }

    s.register(SQLiteConfiguration.self) { c in
        return .init(storage: .connection(.file(path: "db.sqlite")))
    }{{/fluent.db.is_sqlite}}

    s.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateTodo(), to: .{{fluent.db.id}})
        return migrations
    }{{/fluent}}
}

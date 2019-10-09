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
    
    s.extend(Databases.self) { dbs, c in
        try {{fluent.db.extend}}
    }

    s.register({{fluent.db.configType}}.self) { c in
        return {{fluent.db.configInit}}
    }

    s.register(Database.self) { c in
        return try c.make(Databases.self).database(.{{fluent.db.id}})!
    }
    
    s.register(Migrations.self) { c in
        var migrations = Migrations()
        migrations.add(CreateTodo(), to: .{{fluent.db.id}})
        return migrations
    }{{/fluent}}
}

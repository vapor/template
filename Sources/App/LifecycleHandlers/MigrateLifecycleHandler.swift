import FluentKit
import NIOCore
import NIOPosix
import Vapor

struct MigrateLifecycleHandler: LifecycleHandler {
    let databases: Databases
    let migrations: [any Migration]

    init(databases: Databases, migrations: any Migration...) {
        self.databases = databases
        self.migrations = migrations
    }

    func willBoot(_ application: Application) async throws {
        let migrations = Migrations()
        migrations.add(self.migrations)

        let migrator = Migrator(
            databases: databases,
            migrations: migrations,
            logger: application.logger,
            on: MultiThreadedEventLoopGroup.singleton.any()
        )
        try await migrator.setupIfNeeded().get()
        try await migrator.prepareBatch().get()
    }
}

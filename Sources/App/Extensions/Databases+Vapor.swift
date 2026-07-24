import FluentKit
import Logging
import NIOCore
import NIOPosix
import Vapor

extension Databases {
    enum Error: Swift.Error {
        case noDatabaseConfigured
    }

    func database(for request: Request) throws(Error) -> any Database {
        try self.database(logger: request.logger)
    }

    func database(for application: Application) throws(Error) -> any Database {
        try self.database(logger: application.logger)
    }

    private func database(logger: Logger) throws(Error) -> any Database {
        guard let database = self.database(logger: logger, on: MultiThreadedEventLoopGroup.singleton.any()) else {
            throw Error.noDatabaseConfigured
        }
        return database
    }

    func revert(migrations: any Migration..., on application: Application) async throws {
        let container = Migrations()
        container.add(migrations)

        let migrator = Migrator(
            databases: self,
            migrations: container,
            logger: application.logger,
            on: MultiThreadedEventLoopGroup.singleton.any()
        )
        try await migrator.revertAllBatches().get()
    }
}

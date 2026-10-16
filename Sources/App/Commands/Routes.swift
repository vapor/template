import ArgumentParser
import Configuration
import ConsoleLogger
import Logging
import Vapor

struct Routes: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Displays all registered routes.")

    /// Captures all unrecognized command-line arguments
    /// for compatibility with other libraries that use Swift Configuration.
    /// You don't need to pass them to your `ConfigReader`, it will automatically pick them up.
    @Argument(parsing: .allUnrecognized, help: .private)
    var other: [String] = []

    mutating func run() async throws {
        try await withLogger(.init(label: "vapor.logger.routes")) { _ in
            let config = ConfigReader(providers: [
                CommandLineArgumentsProvider(),
                EnvironmentVariablesProvider(),
            ])
            ConsoleLogger.bootstrapWithConfigReader(config: config)
            let app = try Application(configReader: config)
            try await configure(app)
            print(app.routesASCIITable())
            try await app.shutdown()
        }
    }
}

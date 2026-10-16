import ArgumentParser
import Configuration
import ConsoleLogger
import Logging
import Vapor

struct Migrate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Prepare or revert your database migrations.")

    @Flag var revert = false

    /// Captures all unrecognized command-line arguments for compatibility with other libraries that use Swift Configuration.
    @Argument(parsing: .allUnrecognized, help: .private)
    var configArguments: [String]

    mutating func run() async throws {
        try await withLogger(.init(label: "vapor.logger.migrate")) { _ in
            let config = ConfigReader(providers: [
                CommandLineArgumentsProvider(arguments: ["migrate"] + configArguments),
                EnvironmentVariablesProvider(),
            ])
            ConsoleLogger.bootstrapWithConfigReader(config: config)
            let app = try Application(configReader: config)
            print("🚧 Work in progress 🚧")
            try await app.shutdown()
        }
    }
}

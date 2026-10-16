import ArgumentParser
import Configuration
import ConsoleLogger
import Logging
import Vapor

struct Serve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Begins serving the app over HTTP.")

    @Option(help: "The hostname the server will run on.")
    var hostname: String?

    @Option(help: "The port the server will run on.")
    var port: Int?

    @Option(help: "Convenience for setting hostname and port together, in the format `hostname:port`.")
    var bind: String?

    @Option(help: "The path for the Unix domain socket file the server will bind to.")
    var socketPath: String?

    /// Captures all unrecognized command-line arguments for compatibility with other libraries that use Swift Configuration.
    @Argument(parsing: .allUnrecognized, help: .private)
    var configArguments: [String]

    mutating func run() async throws {
        try await withLogger(.init(label: "vapor.logger")) { _ in
            let config = ConfigReader(providers: [
                CommandLineArgumentsProvider(arguments: ["serve"] + configArguments),
                EnvironmentVariablesProvider(),
            ])
            ConsoleLogger.bootstrapWithConfigReader(config: config)

            let app = try Application(configReader: config)
            do {
                try await configure(app)
                try await app.run()
                try await app.shutdown()
            } catch {
                try? await app.shutdown()
                throw error
            }
        }
    }
}

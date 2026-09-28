import ArgumentParser
import Configuration
import ConsoleLogger
import Logging
import Vapor

@main
enum Entrypoint: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
    	subcommands: [
            Serve.self,
            Routes.self,
        ],
        defaultSubcommand: Serve.self
    )

    struct Serve: AsyncParsableCommand {
        @Option(help: "The hostname the server will run on.")
        var hostname: String?

        @Option(help: "The port the server will run on.")
        var port: Int?

        @Option(help: "Convenience for setting hostname and port together, in the format `hostname:port`.")
        var bind: String?

        @Option(help: "The path for the unix domain socket file the server will bind to.")
        var socketPath: String?

        mutating func run() async throws {
            // `@Option`s from ArgumentParser are ignored,
            // they are used only for the `--help` screen.
            try await withLogger(.init(label: "vapor5.logger")) { _ in
                let config = ConfigReader(providers: [
                    CommandLineArgumentsProvider(),
                    EnvironmentVariablesProvider(),
                ])
                ConsoleLogger.bootstrapWithConfigReader(config: config)

                let app = try await Application(configReader: config)
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

    struct Routes: AsyncParsableCommand {
        mutating func run() async throws {
            ConsoleLogger.bootstrapWithConfigReader()
            let app = try await Application()
            try configure(app)
            print(app.routesASCIITable())
            try await app.shutdown()
        }
    }
}

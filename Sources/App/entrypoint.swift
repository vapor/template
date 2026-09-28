import ArgumentParser
import Configuration
import ConsoleLogger
import Logging
import Vapor

@main
struct Entrypoint: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "{{name}}",
    	subcommands: [
            Serve.self,
            Routes.self,
            Migrate.self,
        ],
        defaultSubcommand: Serve.self
    )

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
        static let configuration = CommandConfiguration(abstract: "Displays all registered routes.")

        mutating func run() async throws {
            ConsoleLogger.bootstrapWithConfigReader()
            let app = try await Application()
            try await configure(app)
            print(app.routesASCIITable())
            try await app.shutdown()
        }
    }{{#fluent}}

    struct Migrate: AsyncParsableCommand {
        static let configuration = CommandConfiguration(abstract: "Prepare or revert your database migrations.")

        @Flag var revert = false

        mutating func run() async throws {
            print("🚧 Work in progress 🚧")
        }
    }{{/fluent}}
}

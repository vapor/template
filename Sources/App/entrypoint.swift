import Configuration
import ConsoleLogger
import Logging
import Vapor

@main
struct Entrypoint {
    static func main() async throws {
        let config = ConfigReader(providers: [
            CommandLineArgumentsProvider(),
            EnvironmentVariablesProvider(),
        ])
        ConsoleLogger.bootstrap(config: config)

        let services = Application.ServiceConfiguration(
            logger: .provided(.init(label: "{{name}}.logger"))
        )

        let app = try await Application(configReader: config, services: services)
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

import Configuration
import ConsoleLogger
import Logging
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
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

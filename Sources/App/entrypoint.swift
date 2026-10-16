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
            Routes.self,{{#fluent}}
            Migrate.self,{{/fluent}}
        ],
        defaultSubcommand: Serve.self
    )
}

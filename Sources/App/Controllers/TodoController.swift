import FluentKit
import HTTPTypes
import RoutingKit
import Vapor

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

struct TodoController: RouteCollection {
    let databases: Databases

    init(databases: Databases) {
        self.databases = databases
    }

    func boot(routes: any RoutesBuilder) throws {
        let todos = routes.grouped("todos")

        todos.get(use: self.index)
        todos.post(use: self.create)
        todos.group(":todoID") { todo in
            todo.delete(use: self.delete)
        }
    }

    func index(_ req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: databases.database(for: req)).all().map { $0.toDTO() }
    }

    func create(_ req: Request) async throws -> TodoDTO {
        let todo = try await req.content.decode(TodoDTO.self).toModel()
        try await todo.save(on: databases.database(for: req))
        return todo.toDTO()
    }

    func delete(_ req: Request) async throws -> HTTPStatus {
        guard
            let idString = req.parameters.get("todoID"), let id = UUID(uuidString: idString)
        else {
            throw Abort(.badRequest)
        }
        guard let todo = try await Todo.find(id, on: databases.database(for: req)) else {
            throw Abort(.notFound)
        }
        try await todo.delete(on: databases.database(for: req))
        return .noContent
    }
}

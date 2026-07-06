import FluentKit
import HTTPTypes
import RoutingKit
import Vapor

#if canImport(FoundationEssentials)
    import struct FoundationEssentials.UUID
#else
    import struct Foundation.UUID
#endif

struct TodoController: RouteCollection {
    let db: any Database

    init(database: any Database) {
        self.db = database
    }

    func boot(routes: any RoutesBuilder) throws {
        let todos = routes.grouped("todos")

        todos.get(use: self.index)
        todos.post(use: self.create)
        todos.group(":todoID") { todo in
            todo.delete(use: self.delete)
        }
    }

    @Sendable
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> TodoDTO {
        let todo = try await req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: db)
        return todo.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("todoID").flatMap(UUID.init(uuidString:)) else {
            throw Abort(.badRequest)
        }
        guard let todo = try await Todo.find(id, on: db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: db)
        return .noContent
    }
}

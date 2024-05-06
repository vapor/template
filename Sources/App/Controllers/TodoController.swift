import Fluent
import Vapor

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let todos = routes.grouped("todos")

        todos.get(use: { try await self.index(req: $0) })
        todos.post(use: { try await self.create(req: $0) })
        todos.group(":todoID") { todo in
            todo.delete(use: { try await self.delete(req: $0) })
        }
    }
        
    func index(req: Request) async throws -> [TodoDTO] {
        try await Todo.query(on: req.db).all().map { $0.toDTO() }
    }

    func create(req: Request) async throws -> TodoDTO {
        let todo = try req.content.decode(TodoDTO.self).toModel()

        try await todo.save(on: req.db)
        return todo.toDTO()
    }

    func delete(req: Request) async throws -> HTTPStatus {
        guard let todo = try await Todo.find(req.parameters.get("todoID"), on: req.db) else {
            throw Abort(.notFound)
        }

        try await todo.delete(on: req.db)
        return .noContent
    }
}

@testable import {{name}}
import HTTPTypes
import Testing
import Vapor
import VaporTesting
{{#fluent}}import FluentKit
{{/fluent}}

{{#fluent}}@Suite("App Tests", .serialized, .withApp())
{{/fluent}}{{^fluent}}@Suite("App Tests", .withApp())
{{/fluent}}
struct {{name}}Tests {
    @Test("Test Hello World Route")
    func helloWorld() async throws {
        try await app.testing().test(.get, "hello", afterResponse: { res async in
            #expect(res.status == .ok)
            #expect(res.body.string == "Hello, world!")
        })
    }{{#fluent}}

    @Test("Getting all the Todos")
    func getAllTodos() async throws {
        let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
        try await sampleTodos.create(on: database)

        try await app.testing().test(.get, "todos", afterResponse: { res async throws in
            #expect(res.status == .ok)
            let todos = try await res.content.decode([TodoDTO].self)
            #expect(
                todos.sorted { ($0.title ?? "") < ($1.title ?? "") } ==
                sampleTodos.map { $0.toDTO() }.sorted { ($0.title ?? "") < ($1.title ?? "") }
            )
        })
    }

    @Test("Creating a Todo")
    func createTodo() async throws {
        let newDTO = TodoDTO(id: nil, title: "test")

        try await app.testing().test(.post, "todos", beforeRequest: { req in
            try req.content.encode(newDTO)
        }, afterResponse: { res async throws in
            #expect(res.status == .ok)
            let models = try await Todo.query(on: database).all()
            #expect(models.map { $0.toDTO().title } == [newDTO.title])
        })
    }

    @Test("Deleting a Todo")
    func deleteTodo() async throws {
        let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
        try await testTodos.create(on: database)

        try await app.testing().test(.delete, "todos/\(testTodos[0].requireID())", afterResponse: { res async throws in
            #expect(res.status == .noContent)
            let model = try await Todo.find(testTodos[0].id, on: database)
            #expect(model == nil)
        })
    }{{/fluent}}
}
{{#fluent}}
extension TodoDTO: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
{{/fluent}}

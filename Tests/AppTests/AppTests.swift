@testable import {{name}}
import VaporTesting
import Testing
{{#fluent}}import Fluent
{{/fluent}}

{{#fluent}}@Suite("App Tests with DB", .serialized)
{{/fluent}}{{^fluent}}@Suite("App Tests")
{{/fluent}}
struct {{name}}Tests {
    {{#fluent}}private func withApp(_ test: (Application) async throws -> ()) async throws {
        try await withApp(configure: configure) { app in
            do {
                try await app.autoMigrate()
                try await test(app)
                try await app.autoRevert()
            } catch {
                try? await app.autoRevert()
                throw error
            }
        }
    }
    
    {{/fluent}}@Test("Test Hello World Route")
    func helloWorld() async throws {
        try await withApp{{^fluent}}(configure: configure){{/fluent}} { app in
            try await app.testing().test(.GET, "hello", afterResponse: { res async in
                #expect(res.status == .ok)
                #expect(res.body.string == "Hello, world!")
            })
        }
    }{{#fluent}}
    
    @Test("Getting all the Todos")
    func getAllTodos() async throws {
        try await withApp { app in
            let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
            try await sampleTodos.create(on: app.db)
            
            try await app.testing().test(.GET, "todos", afterResponse: { res async throws in
                #expect(res.status == .ok)
                #expect(try res.content.decode([TodoDTO].self) == sampleTodos.map { $0.toDTO()} )
            })
        }
    }
    
    @Test("Creating a Todo")
    func createTodo() async throws {
        let newDTO = TodoDTO(id: nil, title: "test")
        
        try await withApp { app in
            try await app.testing().test(.POST, "todos", beforeRequest: { req in
                try req.content.encode(newDTO)
            }, afterResponse: { res async throws in
                #expect(res.status == .ok)
                let models = try await Todo.query(on: app.db).all()
                #expect(models.map({ $0.toDTO().title }) == [newDTO.title])
            })
        }
    }
    
    @Test("Deleting a Todo")
    func deleteTodo() async throws {
        let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
        
        try await withApp { app in
            try await testTodos.create(on: app.db)
            
            try await app.testing().test(.DELETE, "todos/\(testTodos[0].requireID())", afterResponse: { res async throws in
                #expect(res.status == .noContent)
                let model = try await Todo.find(testTodos[0].id, on: app.db)
                #expect(model == nil)
            })
        }
    }{{/fluent}}
}
{{#fluent}}

extension TodoDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
{{/fluent}}

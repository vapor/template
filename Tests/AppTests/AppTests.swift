@testable import App
import XCTVapor
{{#fluent}}import Fluent
{{/fluent}}

final class AppTests: XCTestCase {
    var app: Application!
    
    override func setUp() async throws {
        self.app = Application(.testing)
        try await configure(app){{#fluent}}
        try await app.autoMigrate(){{/fluent}}
    }
    
    override func tearDown() async throws { {{#fluent}}
        try await app.autoRevert(){{/fluent}}
        self.app.shutdown()
        self.app = nil
    }
    
    func testHelloWorld() async throws {
        try self.app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }{{#fluent}}
    
    func testTodoIndex() async throws {
        let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
        try await sampleTodos.create(on: self.app.db)
        
        try self.app.test(.GET, "todos", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([TodoDTO].self).sorted(by: { $0.title ?? "" < $1.title ?? "" }),
                sampleTodos.map(\.dto).sorted(by: { $0.title ?? "" < $1.title ?? "" })
            )
        })
    }
    
    func testTodoCreate() async throws {
        let newDTO = TodoDTO(id: nil, title: "test")
        
        try await self.app.test(.POST, "todos", beforeRequest: { req in
            try req.content.encode(newDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let models = try await Todo.query(on: self.app.db).all()
            XCTAssertEqual(models.map(\.dto.title), [newDTO.title])
        })
    }
    
    func testTodoDelete() async throws {
        let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
        try await testTodos.create(on: app.db)
        
        try await self.app.test(.DELETE, "todos/\(testTodos[0].requireID())", afterResponse: { res in
            XCTAssertEqual(res.status, .noContent)
            let model = try await Todo.find(testTodos[0].id, on: self.app.db)
            XCTAssertNil(model)
        })
    }{{/fluent}}
}
{{#fluent}}

extension TodoDTO: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title
    }
}
{{/fluent}}

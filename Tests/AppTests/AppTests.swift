@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    let app: Application!
    
    override func setUp() async throws {
        self.app = Application(.testing)
        try await configure(app)
    }
    
    override func tearDown() async throws {
        self.app.shutdown()
        self.app = nil
    }
    
    func testHelloWorld() async throws {
        try self.app.test(.GET, "hello", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(res.body.string, "Hello, world!")
        })
    }
    
    func testTodoIndex() async throws {
        let sampleTodos = [Todo(title: "sample1"), Todo(title: "sample2")]
        try await sampleTodos.create(on: self.app.db)
        
        try self.app.test(.GET, "todos", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(
                try res.content.decode([TodoDTO].self).sorted(by: \.title),
                sampleTodos.map(\.dto).sorted(by: \.title)
            )
        })
    }
    
    func testTodoCreate() async throws {
        let newDTO = TodoDTO(id: nil, title: "test")
        
        try self.app.test(.POST, "todos", beforeRequest: { req in
            try req.content.encode(newDTO)
        }, afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let models = try await Todo.query(on: self.app.db).all()
            XCTAssertEqual(models.map(\.dto), [newDTO])
        })
    }
    
    func testTodoDelete() async throws {
        let testTodos = [Todo(title: "test1"), Todo(title: "test2")]
        try await testTodos.create(on: app.db)
        
        try self.app.test(.DELETE, "todos/\(testTodos[0].id)", afterResponse: { res in
            XCTAssertEqual(res.status, .ok)
            let model = try await Todo.find(testTodos[0].id, on: self.app.db)
            XCTAssertNil(model)
        })
    }
}

import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "It works" example
    router.get { req in
        #if(leaf) {
        return try req.view().render("welcome")
        } else {
        return "it works!"
        }
    }
    
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "hello, world!"
    }

    #if(leaf) {
    // Says hello
    router.get("hello", String.parameter) #("{") req -> Future<View> in
        return try req.view().render("hello", [
            "name": req.parameters.next(String.self)
        ])
    #("}")
    }

    #if(fluent) {
    // Example of configuring a controller
    let todoController = TodoController()
    router.get("todos", use: todoController.index)
    router.post("todos", use: todoController.create)
    router.delete("todos", Todo.parameter, use: todoController.delete)
    }
}

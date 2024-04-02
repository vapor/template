import Fluent
import Vapor

struct TodoDTO: Content {
    var id: UUID?
    var title: String?
    
    var model: Todo {
        let model = Todo()
        
        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        return model
    }
}

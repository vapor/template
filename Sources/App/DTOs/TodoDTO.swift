import FluentKit
import Vapor

#if canImport(FoundationEssentials)
    import FoundationEssentials
#else
    import Foundation
#endif

struct TodoDTO: Content {
    var id: UUID?
    var title: String?

    func toModel() -> Todo {
        let model = Todo()

        model.id = self.id
        if let title = self.title {
            model.title = title
        }
        return model
    }
}

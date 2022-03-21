import App
import Vapor

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
tis hier nie normaal e die shizzle hier
try configure(app)
try app.run()

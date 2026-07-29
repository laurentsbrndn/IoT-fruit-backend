import Vapor

@main
enum App {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        let app = try await Application.make(env)
        
        try await config(app)
        
        try await app.execute()
        
        try await app.asyncShutdown()
    }
}
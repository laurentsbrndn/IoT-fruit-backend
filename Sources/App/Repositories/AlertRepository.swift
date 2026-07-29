import Fluent
import Vapor

struct AlertRepository {
    let database: Database
    
    func save(_ alert: Alert) async throws {
        try await alert.save(on: database)
    }
}
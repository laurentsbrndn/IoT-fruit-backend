import Fluent
import Vapor

struct DriverRepository {
    let database: Database
    
    func getDriver(by id: UUID) async throws -> Driver? {
        try await Driver.find(id, on: database)
    }
}
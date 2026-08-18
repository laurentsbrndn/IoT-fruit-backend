import Fluent
import Vapor

struct DriverRepository {
    let database: Database
    
    func getAllDrivers() async throws -> [Driver] {
        try await Driver.query(on: database).all()
    }

    func getDriver(by id: UUID) async throws -> Driver? {
        try await Driver.find(id, on: database)
    }
}
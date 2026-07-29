import Fluent
import Vapor

struct SensorRepository {
    let database: Database
    
    func save(_ log: SensorLog) async throws {
        try await log.save(on: database)
    }
    
    func getLatestLog(for truckID: UUID) async throws -> SensorLog? {
        try await SensorLog.query(on: database)
            .filter(\.$truck.$id == truckID)
            .sort(\.$timestamp, .descending)
            .first()
    }
}
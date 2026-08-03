import Fluent
import Vapor

struct SensorRepository {
    let database: Database
    
    func save(_ log: SensorLog) async throws {
        try await log.save(on: database)
    }
    
    func getLatestLog(for deviceId: String) async throws -> SensorLog? {
        try await SensorLog.query(on: database)
            .filter(\.$deviceId == deviceId)
            .sort(\.$timestamp, .descending)
            .first()
    }
}
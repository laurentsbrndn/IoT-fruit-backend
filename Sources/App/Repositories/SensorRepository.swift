import Fluent
import Vapor

struct SensorRepository {
    let database: Database
    
    func save(_ log: SensorLog) async throws {
        try await log.save(on: database)
    }
    
    func getLatestLog(for deviceId: String) async throws -> SensorLog? {
        guard let deviceUUID = UUID(uuidString: deviceId) else { return nil }
        
        return try await SensorLog.query(on: database)
            .join(Shipment.self, on: \SensorLog.$shipment.$id == \Shipment.$id)
            .filter(Shipment.self, \.$device.$id == deviceUUID)
            .with(\.$shipment) { shipment in
                shipment.with(\.$device)
            }
            .sort(\SensorLog.$timestamps, .descending)
            .first()
    }
    
    func getAllLogs(limit: Int = 100) async throws -> [SensorLog] {
        try await SensorLog.query(on: database)
            .with(\.$shipment) { shipment in
                shipment.with(\.$device)
            }
            .sort(\SensorLog.$timestamps, .descending)
            .limit(limit)
            .all()
    }
    
    func getLogs(for deviceId: String, limit: Int = 50) async throws -> [SensorLog] {
        guard let deviceUUID = UUID(uuidString: deviceId) else { return [] }
        
        return try await SensorLog.query(on: database)
            .join(Shipment.self, on: \SensorLog.$shipment.$id == \Shipment.$id)
            .filter(Shipment.self, \.$device.$id == deviceUUID)
            .with(\.$shipment) { shipment in
                shipment.with(\.$device)
            }
            .sort(\SensorLog.$timestamps, .descending)
            .limit(limit)
            .all()
    }
}
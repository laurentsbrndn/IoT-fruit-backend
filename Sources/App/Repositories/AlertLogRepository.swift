import Fluent
import Vapor

struct AlertLogRepository {
    let database: Database
    
    func getAllAlerts() async throws -> [AlertLog] {
        try await AlertLog.query(on: database)
            .with(\.$alertType) // Menarik detail dari tabel alert_types
            .sort(\.$timestamps, .descending)
            .all()
    }
    
    func getAlerts(forShipment shipmentID: UUID) async throws -> [AlertLog] {
        try await AlertLog.query(on: database)
            .filter(\.$shipment.$id == shipmentID)
            .with(\.$alertType)
            .sort(\.$timestamps, .descending)
            .all()
    }
    
    func save(_ alertLog: AlertLog) async throws {
        try await alertLog.save(on: database)
    }
}
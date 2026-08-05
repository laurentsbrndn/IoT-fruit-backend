import Vapor
import Fluent

struct AlertLogController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let alertsRoute = routes.grouped("api", "alerts")
        
        alertsRoute.get(use: getAllAlertsHandler)
        alertsRoute.get("shipment", ":shipmentID", use: getShipmentAlertsHandler)
    }

    func getAllAlertsHandler(_ req: Request) async throws -> [AlertLog] {
        let repository = AlertLogRepository(database: req.db)
        return try await repository.getAllAlerts()
    }

    func getShipmentAlertsHandler(_ req: Request) async throws -> [AlertLog] {
        guard let shipmentIDString = req.parameters.get("shipmentID"),
              let shipmentID = UUID(uuidString: shipmentIDString) else {
            throw Abort(.badRequest, reason: "Format Shipment ID tidak valid.")
        }
        
        let repository = AlertLogRepository(database: req.db)
        return try await repository.getAlerts(forShipment: shipmentID)
    }
}
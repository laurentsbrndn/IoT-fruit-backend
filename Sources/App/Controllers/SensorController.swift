import Vapor
import Fluent

struct SensorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sensorsRoute = routes.grouped("api", "sensors")
        
        sensorsRoute.get(use: getAllLogsHandler)
        sensorsRoute.get("device", ":deviceID", use: getDeviceLogsHandler) 
    }

    func getAllLogsHandler(_ req: Request) async throws -> [SensorLog] {
        let repository = SensorRepository(database: req.db)
        return try await repository.getAllLogs()
    }

    func getDeviceLogsHandler(_ req: Request) async throws -> [SensorLog] {
        guard let deviceID = req.parameters.get("deviceID") else { throw Abort(.badRequest) }
        let repository = SensorRepository(database: req.db)
        return try await repository.getLogsByDevice(deviceId: deviceID)
    }
    
    func getShipmentLogsHandler(_ req: Request) async throws -> [SensorLog] {
        guard let shipmentID = req.parameters.get("shipmentID") else { throw Abort(.badRequest) }
        let repository = SensorRepository(database: req.db)
        return try await repository.getLogsByShipment(shipmentId: shipmentID)
    }
}
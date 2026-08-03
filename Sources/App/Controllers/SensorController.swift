import Vapor
import Fluent

struct SensorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sensorsRoute = routes.grouped("api", "sensors")
        
        sensorsRoute.get(use: getAllLogsHandler)
        sensorsRoute.get(":deviceID", use: getDeviceLogsHandler)
    }

    func getAllLogsHandler(_ req: Request) async throws -> [SensorLog] {
        try await SensorLog.query(on: req.db)
            .sort(\.$timestamp, .descending)
            .limit(100)
            .all()
    }

    func getDeviceLogsHandler(_ req: Request) async throws -> [SensorLog] {
        guard let deviceID = req.parameters.get("deviceID") else {
            throw Abort(.badRequest, reason: "Parameter Device ID tidak valid")
        }
        
        return try await SensorLog.query(on: req.db)
            .filter(\.$deviceId == deviceID)
            .sort(\.$timestamp, .descending)
            .limit(50) 
            .all()
    }
}
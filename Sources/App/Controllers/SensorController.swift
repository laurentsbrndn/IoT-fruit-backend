import Vapor
import Fluent

struct SensorController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let sensorsRoute = routes.grouped("api", "sensors")
        
        sensorsRoute.get(use: getAllLogsHandler)
        sensorsRoute.get(":deviceID", use: getDeviceLogsHandler)
    }

    func getAllLogsHandler(_ req: Request) async throws -> [SensorLog] {
        let repository = SensorRepository(database: req.db)
        return try await repository.getAllLogs()
    }

    func getDeviceLogsHandler(_ req: Request) async throws -> [SensorLog] {
        guard let deviceID = req.parameters.get("deviceID") else {
            throw Abort(.badRequest, reason: "Parameter Device ID tidak valid")
        }
        
        let repository = SensorRepository(database: req.db)
        return try await repository.getLogs(for: deviceID)
    }
}
import Vapor
import Fluent

struct DriverController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let driversRoute = routes.grouped("api", "drivers")
        
        driversRoute.get(":driverID", "name", use: getDriverNameHandler)
    }

    func getDriverNameHandler(_ req: Request) async throws -> [String: String] {
        guard let driverIDString = req.parameters.get("driverID"),
              let driverID = UUID(uuidString: driverIDString) else {
            throw Abort(.badRequest, reason: "Format Driver ID tidak valid (Harus UUID).")
        }
        
        let repository = DriverRepository(database: req.db)
        guard let driver = try await repository.getDriver(by: driverID) else {
            throw Abort(.notFound, reason: "Driver dengan ID tersebut tidak ditemukan.")
        }
        
        return ["driver_name": driver.driverName]
    }
}
import Vapor
import Fluent

struct DriverController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let driversRoute = routes.grouped("api", "drivers")
        
        driversRoute.get(use: getAllDriversHandler)
        driversRoute.get(":driverID", "name", use: getDriverNameHandler)
    }

    func getAllDriversHandler(_ req: Request) async throws -> [[String: String]] {
        let repository = DriverRepository(database: req.db)
        let drivers = try await repository.getAllDrivers()
        
        return drivers.compactMap { driver -> [String: String]? in
            guard let id = driver.id?.uuidString else { return nil }
            return [
                "driver_id": id,
                "driver_name": driver.driverName,
                "driver_phone_number": driver.driverPhoneNumber
            ]
        }
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
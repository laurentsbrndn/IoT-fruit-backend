import Vapor
import Fluent

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let devicesRoute = routes.grouped("api", "devices")
        
        devicesRoute.get(use: getAllDevicesHandler)
    }

    func getAllDevicesHandler(_ req: Request) async throws -> [[String: String]] {
        let repository = DeviceRepository(database: req.db)
        
        let devices = try await repository.getAllDevices()
        
        let formattedDevices = devices.compactMap { device -> [String: String]? in
            guard let id = device.id?.uuidString else { return nil }
            return [
                "device_id": id,
                "device_name": device.deviceName
            ]
        }
        
        return formattedDevices
    }
}
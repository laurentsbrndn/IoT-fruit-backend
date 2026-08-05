import Vapor
import Fluent

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let devicesRoute = routes.grouped("api", "devices")
        
        devicesRoute.get(use: getAllDevicesHandler)
        devicesRoute.get("name", ":deviceName", use: getDeviceByNameHandler)
    }

    func getAllDevicesHandler(_ req: Request) async throws -> [[String: String]] {
        let repository = DeviceRepository(database: req.db)
        let devices = try await repository.getAllDevices()
        
        return devices.compactMap { device -> [String: String]? in
            guard let id = device.id?.uuidString else { return nil }
            return [
                "device_id": id,
                "device_name": device.deviceName
            ]
        }
    }

    func getDeviceByNameHandler(_ req: Request) async throws -> [String: String] {
        guard let deviceName = req.parameters.get("deviceName") else {
            throw Abort(.badRequest, reason: "Parameter Device Name tidak valid.")
        }
        
        let repository = DeviceRepository(database: req.db)
        guard let device = try await repository.getDevice(byName: deviceName) else {
            throw Abort(.notFound, reason: "Device dengan nama '\(deviceName)' tidak ditemukan.")
        }
        
        guard let id = device.id?.uuidString else {
            throw Abort(.internalServerError)
        }
        
        return [
            "device_id": id,
            "device_name": device.deviceName
        ]
    }
}
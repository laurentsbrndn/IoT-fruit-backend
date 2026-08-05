import Fluent
import Vapor

struct DeviceRepository {
    let database: Database
    
    func getAllDevices() async throws -> [Device] {
        try await Device.query(on: database).all()
    }
    
    func getDevice(byName name: String) async throws -> Device? {
        try await Device.query(on: database)
            .filter(\.$deviceName == name)
            .first()
    }
}
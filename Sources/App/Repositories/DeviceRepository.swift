import Fluent
import Vapor

struct DeviceRepository {
    let database: Database
    
    func getAllDevices() async throws -> [Device] {
        try await Device.query(on: database).all()
    }
    
    func getDevice(by id: UUID) async throws -> Device? {
        try await Device.find(id, on: database)
    }
}
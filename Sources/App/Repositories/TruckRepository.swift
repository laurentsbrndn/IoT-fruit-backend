import Fluent
import Vapor

struct TruckRepository {
    let database: Database
    
    func findByDeviceID(_ deviceID: String) async throws -> Truck? {
        try await Truck.query(on: database)
            .filter(\.$deviceID == deviceID)
            .first()
    }
    
    func create(_ truck: Truck) async throws {
        try await truck.save(on: database)
    }
}
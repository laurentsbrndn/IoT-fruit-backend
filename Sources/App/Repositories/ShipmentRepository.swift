import Fluent
import Vapor

struct ShipmentRepository {
    let database: Database

    func getAllShipments() async throws -> [Shipment] {
        try await Shipment.query(on: database)
            .with(\.$device)
            .with(\.$driver)
            .sort(\.$startDate, .descending)
            .all()
    }
    
    func getActiveShipments() async throws -> [Shipment] {
        try await Shipment.query(on: database)
            .filter(\.$endDate == nil)
            .with(\.$device)
            .with(\.$driver)
            .sort(\.$startDate, .descending)
            .all()
    }
    
    func getShipment(by id: UUID) async throws -> Shipment? {
        try await Shipment.query(on: database)
            .filter(\.$id == id)
            .with(\.$device)
            .with(\.$driver)
            .first()
    }
    
    func create(_ shipment: Shipment) async throws {
        try await shipment.save(on: database)
    }
    
    func update(_ shipment: Shipment) async throws {
        try await shipment.update(on: database)
    }
}
import Vapor
import Fluent

struct ShipmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let shipmentsRoute = routes.grouped("api", "shipments")
        
        shipmentsRoute.get(use: getAllShipmentsHandler)
        
        shipmentsRoute.get("active", use: getActiveShipmentsHandler)
        
        shipmentsRoute.get(":shipmentID", use: getShipmentHandler)
    }

    func getAllShipmentsHandler(_ req: Request) async throws -> [Shipment] {
        let repository = ShipmentRepository(database: req.db)
        return try await repository.getAllShipments()
    }
    
    func getActiveShipmentsHandler(_ req: Request) async throws -> [Shipment] {
        let repository = ShipmentRepository(database: req.db)
        return try await repository.getActiveShipments()
    }

    func getShipmentHandler(_ req: Request) async throws -> Shipment {
        guard let shipmentIDString = req.parameters.get("shipmentID"),
              let shipmentID = UUID(uuidString: shipmentIDString) else {
            throw Abort(.badRequest, reason: "Format Shipment ID tidak valid.")
        }
        
        let repository = ShipmentRepository(database: req.db)
        
        guard let shipment = try await repository.getShipment(by: shipmentID) else {
            throw Abort(.notFound, reason: "Data pengiriman (Shipment) tidak ditemukan.")
        }
        
        return shipment
    }
}
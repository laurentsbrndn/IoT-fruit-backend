import Vapor
import Fluent

struct ShipmentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let shipmentsRoute = routes.grouped("api", "shipments")
        
        shipmentsRoute.get(use: getAllShipmentsHandler)
        shipmentsRoute.get("active", use: getActiveShipmentsHandler)
        shipmentsRoute.get(":shipmentID", use: getShipmentHandler)

        shipmentsRoute.post(use: startShipmentHandler)

        shipmentsRoute.put(":shipmentID", use: updateShipmentHandler)
        
        shipmentsRoute.patch(":shipmentID", "finish", use: finishShipmentHandler)
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

    func startShipmentHandler(_ req: Request) async throws -> HTTPStatus {
        let dto = try req.content.decode(StartShipmentDTO.self)
        
        guard let deviceUUID = UUID(uuidString: dto.deviceId),
            let driverUUID = UUID(uuidString: dto.driverId) else {
            throw Abort(.badRequest, reason: "Format Device ID atau Driver ID tidak valid.")
        }
        
        let newShipment = Shipment(
            deviceID: deviceUUID,
            driverID: driverUUID,
            truckPlateNumber: dto.truckPlateNumber,
            startDate: Date(),
            startLatitude: dto.startLatitude, 
            startLongitude: dto.startLongitude,
            endLatitude: dto.endLatitude,      
            endLongitude: dto.endLongitude     
        )
        
        let repository = ShipmentRepository(database: req.db)
        try await repository.create(newShipment)
        
        return .created
    }

    func finishShipmentHandler(_ req: Request) async throws -> HTTPStatus {
        guard let shipmentIDString = req.parameters.get("shipmentID"),
              let shipmentID = UUID(uuidString: shipmentIDString) else {
            throw Abort(.badRequest, reason: "Format Shipment ID tidak valid.")
        }
        
        let dto = try req.content.decode(FinishShipmentDTO.self)
        
        let repository = ShipmentRepository(database: req.db)
        guard let shipment = try await repository.getShipment(by: shipmentID) else {
            throw Abort(.notFound, reason: "Data pengiriman tidak ditemukan.")
        }
        
        guard shipment.endDate == nil else {
            throw Abort(.badRequest, reason: "Pengiriman ini sudah diselesaikan sebelumnya.")
        }
        
        shipment.endDate = Date()
        shipment.endLatitude = dto.endLatitude
        shipment.endLongitude = dto.endLongitude
        
        try await repository.update(shipment)
        
        return .ok
    }

    func updateShipmentHandler(_ req: Request) async throws -> Shipment {
        guard let shipmentIDString = req.parameters.get("shipmentID"),
              let shipmentID = UUID(uuidString: shipmentIDString) else {
            throw Abort(.badRequest, reason: "Format Shipment ID tidak valid.")
        }
        
        let dto = try req.content.decode(UpdateShipmentDTO.self)
        
        guard let deviceUUID = UUID(uuidString: dto.deviceId),
              let driverUUID = UUID(uuidString: dto.driverId) else {
            throw Abort(.badRequest, reason: "Format Device ID atau Driver ID tidak valid.")
        }
        
        let repository = ShipmentRepository(database: req.db)
        
        guard let shipment = try await repository.getShipment(by: shipmentID) else {
            throw Abort(.notFound, reason: "Data pengiriman (Shipment) tidak ditemukan.")
        }
        
        shipment.$device.id = deviceUUID
        shipment.$driver.id = driverUUID
        shipment.truckPlateNumber = dto.truckPlateNumber
        shipment.startDate = dto.startDate
        shipment.endDate = dto.endDate
        shipment.startLatitude = dto.startLatitude
        shipment.startLongitude = dto.startLongitude
        shipment.endLatitude = dto.endLatitude
        shipment.endLongitude = dto.endLongitude
        
        try await repository.update(shipment)
        
        return shipment
    }
}
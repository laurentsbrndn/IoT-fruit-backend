import Vapor
import Fluent

struct TruckController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let trucksRoute = routes.grouped("api", "trucks")
        
        trucksRoute.get(use: getAllTrucksHandler)
        trucksRoute.get(":truckID", use: getSingleTruckHandler)
        trucksRoute.get(":truckID", "telemetry", use: getTelemetryHistoryHandler)
    }

    func getAllTrucksHandler(_ req: Request) async throws -> [Truck] {
        try await Truck.query(on: req.db).all()
    }

    func getSingleTruckHandler(_ req: Request) async throws -> Truck {
        guard let deviceID = req.parameters.get("truckID") else {
            throw Abort(.badRequest, reason: "Parameter Device ID tidak valid")
        }
        
        guard let truck = try await Truck.query(on: req.db)
            .filter(\.$deviceID == deviceID)
            .first() else {
            throw Abort(.notFound, reason: "Truk tidak ditemukan")
        }
        return truck
    }

    func getTelemetryHistoryHandler(_ req: Request) async throws -> [SensorLog] {
        guard let deviceID = req.parameters.get("truckID") else {
            throw Abort(.badRequest, reason: "Parameter Device ID tidak valid")
        }
        
        guard let truck = try await Truck.query(on: req.db)
            .filter(\.$deviceID == deviceID)
            .first() else {
            throw Abort(.notFound, reason: "Truk tidak ditemukan")
        }
        
        let truckID = try truck.requireID()
        
        return try await SensorLog.query(on: req.db)
            .filter(\.$truck.$id == truckID)
            .sort(\.$timestamp, .descending)
            .limit(50) 
            .all()
    }
}
import Vapor
import Fluent

struct AlertController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let alertsRoute = routes.grouped("api", "alerts")
        
        alertsRoute.get(use: getAllAlertsHandler)
    }

    func getAllAlertsHandler(_ req: Request) async throws -> [Alert] {
        try await Alert.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .limit(20)
            .all()
    }
}
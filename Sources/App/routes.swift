import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "API Dashboard Monitoring is Running!"
    }
    
    try app.register(collection: SensorController())
    try app.register(collection: DeviceController())
    try app.register(collection: DriverController())
    try app.register(collection: AlertLogController())
    try app.register(collection: ShipmentController())
    
    app.webSocket("api", "live-telemetry") { req, ws in
        Task {
            await WebSocketManager.shared.connect(ws)
        }
    }
}
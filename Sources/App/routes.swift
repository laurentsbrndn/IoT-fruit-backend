import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "API Dashboard Monitoring is Running!"
    }
    
    // ==========================================
    // SENSOR LOGS API
    // - GET /api/sensors
    // - GET /api/sensors/shipment/:shipmentID
    // ==========================================
    try app.register(collection: SensorController())
    
    // ==========================================
    // DEVICES API
    // - GET /api/devices
    // - GET /api/devices/name/:deviceName
    // ==========================================
    try app.register(collection: DeviceController())
    
    // ==========================================
    // DRIVERS API
    // - GET /api/drivers/:driverID/name
    // ==========================================
    try app.register(collection: DriverController())
    
    // ==========================================
    // ALERT LOGS API
    // - GET /api/alerts
    // - GET /api/alerts/shipment/:shipmentID
    // ==========================================
    try app.register(collection: AlertLogController())
    
    // ==========================================
    // SHIPMENTS API
    // - GET /api/shipments
    // - GET /api/shipments/active
    // - GET /api/shipments/:shipmentID
    // - POST /api/shipments
    // - PATCH /api/shipments/:shipmentID/finish
    // ==========================================
    try app.register(collection: ShipmentController())
    
    // ==========================================
    // WEBSOCKET
    // - WS /api/live-telemetry
    // ==========================================
    app.webSocket("api", "live-telemetry") { req, ws in
        Task {
            await WebSocketManager.shared.connect(ws)
        }
    }
}
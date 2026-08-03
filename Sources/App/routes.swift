import Vapor

func routes(_ app: Application) throws {
    app.get { req async in
        "API Dashboard Monitoring is Running!"
    }
    
    try app.register(collection: SensorController())
    
    app.webSocket("api", "live-telemetry") { req, ws in
        Task {
            await WebSocketManager.shared.connect(ws)
        }
    }
}
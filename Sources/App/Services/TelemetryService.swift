import Vapor
import Fluent

struct TelemetryService {
    let app: Application
    
    func processIncomingData(_ dto: MQTTTelemetryDTO) async throws {
        let db = app.db
        let sensorRepo = SensorRepository(database: db)
        
        let sensorLog = SensorLog(
            deviceId: dto.device_id,
            temperature: dto.temperature,
            humidity: dto.humidity,
            latitude: dto.latitude,
            longitude: dto.longitude,
            battery: dto.battery,
            timestamp: dto.timestamp
        )
        
        try await sensorRepo.save(sensorLog)
        
        await WebSocketManager.shared.broadcast(telemetry: dto)
        app.logger.info("Berhasil memproses telemetri dari \(dto.device_id).")
    }
}
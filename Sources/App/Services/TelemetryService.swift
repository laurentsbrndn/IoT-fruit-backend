import Vapor
import Fluent

struct TelemetryService {
    let app: Application
    
    func processIncomingData(_ dto: MQTTTelemetryDTO) async throws {
        let db = app.db
        let truckRepo = TruckRepository(database: db)
        let sensorRepo = SensorRepository(database: db)
        let alertRepo = AlertRepository(database: db)
        
        guard let truck = try await truckRepo.findByDeviceID(dto.device_id) else {
            app.logger.warning("⚠️ Data masuk dari device_id: \(dto.device_id), tapi truk tidak ditemukan di database.")
            return
        }
        
        let truckID = try truck.requireID()
        
        let sensorLog = SensorLog(
            truckID: truckID,
            temperature: dto.temperature,
            humidity: dto.humidity,
            latitude: dto.latitude,
            longitude: dto.longitude,
            battery: dto.battery,
            timestamp: dto.timestamp
        )
        try await sensorRepo.save(sensorLog)
        
        if dto.status != "NORMAL" {
            let severity = dto.status == "WARNING" ? "CRITICAL" : "WARNING"
            let message = "Terdeteksi anomali: \(dto.status). Suhu saat ini: \(dto.temperature)°C, Kelembapan: \(dto.humidity)%."
            
            let alert = Alert(
                truckID: truckID,
                type: dto.status,
                message: message,
                severity: severity
            )
            try await alertRepo.save(alert)
            
            app.logger.notice("Alert disimpan untuk truk \(truck.truckName) - \(message)")
        }
        await WebSocketManager.shared.broadcast(telemetry: dto)

        app.logger.info("Berhasil memproses telemetri dari \(dto.device_id).")
    }
}
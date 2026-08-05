import Vapor
import Fluent

struct TelemetryService {
    let app: Application
    
    func processIncomingData(_ dto: MQTTTelemetryDTO) async throws {
        let db = app.db

        guard let deviceUUID = UUID(uuidString: dto.deviceId) else {
            app.logger.error("Format device_id tidak valid dari telemetri: \(dto.deviceId)")
            return
        }
        
        guard let activeShipment = try await Shipment.query(on: db)
            .filter(\.$device.$id == deviceUUID)
            .filter(\.$endDate == nil)
            .first() 
        else {
            app.logger.warning("Mengabaikan data: Tidak ada shipment aktif untuk device \(dto.deviceId)")
            return
        }
        
        let currentShipmentID = try activeShipment.requireID()
        
        let sensorLog = SensorLog(
            shipmentID: currentShipmentID,
            temperature: dto.temperature,
            humidity: dto.humidity,
            latitude: dto.latitude,
            longitude: dto.longitude,
            batteryPercentage: dto.batteryPercentage,
            timestamps: dto.timestamps ?? Date()
        )
        
        try await sensorLog.save(on: db)
        
        await WebSocketManager.shared.broadcast(telemetry: dto)
        
        app.logger.info("Berhasil menyimpan telemetri untuk Device: \(dto.deviceId) ke Shipment: \(currentShipmentID).")
    }
}
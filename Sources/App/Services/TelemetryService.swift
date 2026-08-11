import Vapor
import Fluent

struct TelemetryService {
    let app: Application
    
    // func processIncomingData(_ dto: MQTTTelemetryDTO) async throws {
    //     let db = app.db
        
    //     guard let deviceUUID = UUID(uuidString: dto.deviceId) else {
    //         app.logger.error("Format device_id tidak valid dari telemetri: \(dto.deviceId)")
    //         return
    //     }
        
    //     guard let activeShipment = try await Shipment.query(on: db)
    //         .filter(\.$device.$id == deviceUUID)
    //         .filter(\.$endDate == nil)
    //         .first() 
    //     else {
    //         app.logger.warning("Mengabaikan data: Tidak ada shipment aktif untuk device \(dto.deviceId)")
    //         return
    //     }
        
    //     let currentShipmentID = try activeShipment.requireID()
        
    //     let sensorLog = SensorLog(
    //         shipmentID: currentShipmentID,
    //         temperature: dto.temperature,
    //         humidity: dto.humidity,
    //         latitude: dto.latitude,
    //         longitude: dto.longitude,
    //         batteryPercentage: dto.batteryPercentage,
    //         timestamps: dto.timestamps ?? Date()
    //     )
        
    //     try await sensorLog.save(on: db)
    //     let currentSensorLogID = try sensorLog.requireID()
        
    //     if let temp = dto.temperature, temp > 30.0 {
    //         if let alertType = try await AlertType.query(on: db)
    //             .filter(\.$title == "Suhu Terlalu Panas")
    //             .first() {
                
    //             let alertLog = AlertLog(
    //                 alertTypeID: try alertType.requireID(),
    //                 shipmentID: currentShipmentID,
    //                 sensorLogID: currentSensorLogID,
    //                 timestamps: Date()
    //             )
    //             try await alertLog.save(on: db)
    //             app.logger.warning("⚠️ ALERT TER-TRIGGER: Suhu mencapai \(temp)°C")
    //         }
    //     }
        
    //     if let battery = dto.batteryPercentage, battery < 15.0 {
    //         if let alertType = try await AlertType.query(on: db)
    //             .filter(\.$title == "Baterai Lemah")
    //             .first() {
                
    //             let alertLog = AlertLog(
    //                 alertTypeID: try alertType.requireID(),
    //                 shipmentID: currentShipmentID,
    //                 sensorLogID: currentSensorLogID,
    //                 timestamps: Date()
    //             )
    //             try await alertLog.save(on: db)
    //             app.logger.warning("⚠️ ALERT TER-TRIGGER: Baterai tersisa \(battery)%")
    //         }
    //     }
        
    //     await WebSocketManager.shared.broadcast(telemetry: dto)
        
    //     app.logger.info("Berhasil menyimpan telemetri untuk Device: \(dto.deviceId).")
    // }

    func processIncomingData(_ dto: MQTTBatchedTelemetryDTO) async throws {
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
        
        for item in dto.log {
            let validLatitudes = item.latitude?.compactMap { $0 }
            let validLongitudes = item.longitude?.compactMap { $0 }
            let recordDate = item.timestamp != nil ? Date(timeIntervalSince1970: TimeInterval(item.timestamp!)) : Date()
            
            let sensorLog = SensorLog(
                shipmentID: currentShipmentID,
                temperature: item.temperature,
                humidity: item.humidity,
                latitude: validLatitudes,
                longitude: validLongitudes,
                timestamps: recordDate
            )
            
            try await sensorLog.save(on: db)
            let currentSensorLogID = try sensorLog.requireID()
            
            if let temp = item.temperature, temp > 30.0 {
                if let alertType = try await AlertType.query(on: db)
                    .filter(\.$title == "Suhu Terlalu Panas")
                    .first() {
                    
                    let alertLog = AlertLog(
                        alertTypeID: try alertType.requireID(),
                        shipmentID: currentShipmentID,
                        sensorLogID: currentSensorLogID,
                        timestamps: Date()
                    )
                    try await alertLog.save(on: db)
                    app.logger.warning("⚠️ ALERT TER-TRIGGER: Suhu mencapai \(temp)°C")
                }
            }
            
        }
        
        await WebSocketManager.shared.broadcast(telemetry: dto)
        
        app.logger.info("Berhasil menyimpan telemetri untuk Device: \(dto.deviceId).")
    }
}
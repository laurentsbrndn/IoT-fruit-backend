import Vapor
import Fluent

struct TelemetryService {
    let app: Application
    
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
        
        let allAlertTypes = try await AlertType.query(on: db).all()
        let alertDict = Dictionary(uniqueKeysWithValues: allAlertTypes.map { ($0.title, $0) })
        
        let lastAlerts = try await AlertLog.query(on: db)
            .join(AlertType.self, on: \AlertLog.$alertType.$id == \AlertType.$id)
            .filter(\.$shipment.$id == currentShipmentID)
            .sort(\.$timestamps, .descending)
            .all()
            
        var currentTempState = lastAlerts.first(where: {
            (try? $0.joined(AlertType.self).category == "temperature") ?? false
        })
        .flatMap {
            try? $0.joined(AlertType.self).title
        } ?? "Temperature Normalized"

        var currentHumidState = lastAlerts.first(where: {
            (try? $0.joined(AlertType.self).category == "humidity") ?? false
        })
        .flatMap {
            try? $0.joined(AlertType.self).title
        } ?? "Humidity Normalized"

        var currentConnState = lastAlerts.first(where: {
            (try? $0.joined(AlertType.self).category == "connection") ?? false
        })
        .flatMap {
            try? $0.joined(AlertType.self).title
        } ?? "Connection Back"

        var isConnectionBackTriggered = false
        
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
            
            if currentConnState == "Lost Connection" && !isConnectionBackTriggered {
                if let alertType = alertDict["Connection Back"] {
                    let alertLog = AlertLog(alertTypeID: try alertType.requireID(), shipmentID: currentShipmentID, sensorLogID: currentSensorLogID, timestamps: recordDate)
                    try await alertLog.save(on: db)
                    
                    currentConnState = "Connection Back"
                    isConnectionBackTriggered = true
                    app.logger.info("🔗 ALERT: Sensor is back online (Connection Back)")
                }
            }
            
            if let temp = item.temperature {
                var newTempState = currentTempState
                
                if temp > 13.0 { newTempState = "High Temperature" }
                else if temp < 10.0 { newTempState = "Low Temperature" }
                else { newTempState = "Temperature Normalized" }
                
                // Hanya simpan ke DB jika ada PERUBAHAN status
                if newTempState != currentTempState, let alertType = alertDict[newTempState] {
                    let alertLog = AlertLog(alertTypeID: try alertType.requireID(), shipmentID: currentShipmentID, sensorLogID: currentSensorLogID, timestamps: recordDate)
                    try await alertLog.save(on: db)
                    
                    currentTempState = newTempState
                    app.logger.warning("🌡️ ALERT: \(newTempState) (\(temp)°C)")
                }
            }
            
            if let humid = item.humidity {
                var newHumidState = currentHumidState
                
                if humid > 95.0 { newHumidState = "High Humidity" }
                else if humid < 85.0 { newHumidState = "Low Humidity" }
                else { newHumidState = "Humidity Normalized" }
                
                if newHumidState != currentHumidState, let alertType = alertDict[newHumidState] {
                    let alertLog = AlertLog(alertTypeID: try alertType.requireID(), shipmentID: currentShipmentID, sensorLogID: currentSensorLogID, timestamps: recordDate)
                    try await alertLog.save(on: db)
                    
                    currentHumidState = newHumidState
                    app.logger.warning("💧 ALERT: \(newHumidState) (\(humid)%)")
                }
            }
        }
        
        await WebSocketManager.shared.broadcast(telemetry: dto)
        app.logger.info("Berhasil memproses batch telemetri untuk Device: \(dto.deviceId).")
    }
}
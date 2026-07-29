import Vapor

struct MQTTSubscriber {
    let app: Application
    
    func handleIncomingMessage(topic: String, payload: Data) {
        guard topic == MQTTTopics.telemetry else { return }
        
        do {
            let telemetryDTO = try MQTTDecoder.decode(payload: payload)
            Task {
                do {
                    try await app.telemetryService.processIncomingData(telemetryDTO)
                } catch {
                    app.logger.error("Gagal menyimpan data telemetri: \(error)")
                }
            }
            
        } catch {
            app.logger.error("Gagal decode payload MQTT: \(error)")
        }
    }
}
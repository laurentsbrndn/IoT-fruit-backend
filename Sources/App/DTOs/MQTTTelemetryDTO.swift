import Vapor

struct MQTTBatchedTelemetryDTO: Content {
    let deviceId: String
    let log: [MQTTTelemetryItemDTO]
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case log
    }
}

struct MQTTTelemetryItemDTO: Content {
    let timestamp: Int?
    let temperature: Double?
    let humidity: Double?
    let latitude: [Double?]?
    let longitude: [Double?]?
}
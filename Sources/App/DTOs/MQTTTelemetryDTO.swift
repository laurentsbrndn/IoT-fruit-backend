import Vapor

struct MQTTTelemetryDTO: Content {
    let device_id: String
    let timestamp: Date
    let temperature: Double
    let humidity: Double
    let latitude: Double
    let longitude: Double
    let battery: Int
    let status: String
}
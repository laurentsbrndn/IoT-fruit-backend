import Vapor

struct MQTTTelemetryDTO: Content {
    let deviceId: String
    let timestamps: Date?
    let temperature: Double?
    let humidity: Double?
    
    let latitude: [Double]?
    let longitude: [Double]?
    
    let batteryPercentage: Double?
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case timestamps = "sensor_log_timestamps" 
        case temperature = "sensor_log_temperature"
        case humidity = "sensor_log_humidity"
        case latitude = "sensor_log_latitude"
        case longitude = "sensor_log_longitude"
        case batteryPercentage = "sensor_log_battery_percentage"
    }
}
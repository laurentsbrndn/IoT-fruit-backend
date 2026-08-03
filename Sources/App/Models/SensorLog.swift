import Fluent
import Vapor

final class SensorLog: Model, Content, @unchecked Sendable {
    static let schema = "sensor_logs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "device_id")
    var deviceId: String
    
    @Field(key: "temperature")
    var temperature: Double
    
    @Field(key: "humidity")
    var humidity: Double
    
    @Field(key: "latitude")
    var latitude: Double
    
    @Field(key: "longitude")
    var longitude: Double
    
    @OptionalField(key: "battery")
    var battery: Int?
    
    @Field(key: "timestamp")
    var timestamp: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, deviceId: String, temperature: Double, humidity: Double, latitude: Double, longitude: Double, battery: Int?, timestamp: Date) {
        self.id = id
        self.deviceId = deviceId
        self.temperature = temperature
        self.humidity = humidity
        self.latitude = latitude
        self.longitude = longitude
        self.battery = battery
        self.timestamp = timestamp
    }
}
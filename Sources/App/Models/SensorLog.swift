import Fluent
import Vapor

final class SensorLog: Model, Content, @unchecked Sendable {
    static let schema = "sensor_logs"
    
    @ID(custom: "sensor_log_id", generatedBy: .random)
    var id: UUID?
    
    @Parent(key: "shipment_id")
    var shipment: Shipment
    
    @OptionalField(key: "sensor_log_temperature")
    var temperature: Double?
    
    @OptionalField(key: "sensor_log_humidity")
    var humidity: Double?
    
    @OptionalField(key: "sensor_log_latitude")
    var latitude: [Double]?

    @OptionalField(key: "sensor_log_longitude")
    var longitude: [Double]?
    
    @OptionalField(key: "sensor_log_timestamps")
    var timestamps: Date?
    
    init() { }
    
    init(id: UUID? = nil, shipmentID: UUID, temperature: Double? = nil, humidity: Double? = nil, latitude: [Double]? = nil, longitude: [Double]? = nil, timestamps: Date? = nil) {
        self.id = id
        self.$shipment.id = shipmentID
        self.temperature = temperature
        self.humidity = humidity
        self.latitude = latitude
        self.longitude = longitude
        self.timestamps = timestamps
    }
}
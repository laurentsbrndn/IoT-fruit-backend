import Fluent
import Vapor

final class SensorLog: Model, Content {
    static let schema = "sensor_logs"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "truck_id")
    var truck: Truck
    
    @Field(key: "temperature")
    var temperature: Double
    
    @Field(key: "humidity")
    var humidity: Double
    
    @Field(key: "latitude")
    var latitude: Double
    
    @Field(key: "longitude")
    var longitude: Double
    
    @Field(key: "battery")
    var battery: Int
    
    @Field(key: "timestamp")
    var timestamp: Date
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, truckID: Truck.IDValue, temperature: Double, humidity: Double, latitude: Double, longitude: Double, battery: Int, timestamp: Date) {
        self.id = id
        self.$truck.id = truckID
        self.temperature = temperature
        self.humidity = humidity
        self.latitude = latitude
        self.longitude = longitude
        self.battery = battery
        self.timestamp = timestamp
    }
}
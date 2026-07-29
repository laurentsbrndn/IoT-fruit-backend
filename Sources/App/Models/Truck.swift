import Fluent
import Vapor

final class Truck: Model, Content {
    static let schema = "trucks"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "device_id")
    var deviceID: String
    
    @Field(key: "truck_name")
    var truckName: String
    
    @Field(key: "plate_number")
    var plateNumber: String
    
    @Field(key: "status")
    var status: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    @Children(for: \.$truck)
    var sensorLogs: [SensorLog]
    
    @Children(for: \.$truck)
    var alerts: [Alert]
    
    init() { }
    
    init(id: UUID? = nil, deviceID: String, truckName: String, plateNumber: String, status: String) {
        self.id = id
        self.deviceID = deviceID
        self.truckName = truckName
        self.plateNumber = plateNumber
        self.status = status
    }
}
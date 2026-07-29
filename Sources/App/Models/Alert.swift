import Fluent
import Vapor

final class Alert: Model, Content {
    static let schema = "alerts"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "truck_id")
    var truck: Truck
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "message")
    var message: String
    
    @Field(key: "severity")
    var severity: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
    
    init() { }
    
    init(id: UUID? = nil, truckID: Truck.IDValue, type: String, message: String, severity: String) {
        self.id = id
        self.$truck.id = truckID
        self.type = type
        self.message = message
        self.severity = severity
    }
}
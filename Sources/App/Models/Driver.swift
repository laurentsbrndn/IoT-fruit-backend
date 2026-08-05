import Fluent
import Vapor

final class Driver: Model, Content, @unchecked Sendable {
    static let schema = "drivers"
    
    @ID(custom: "driver_id", generatedBy: .random)
    var id: UUID?
    
    @Field(key: "driver_name")
    var driverName: String
    
    @Field(key: "driver_phone_number")
    var driverPhoneNumber: String
    
    init() { }
    
    init(id: UUID? = nil, driverName: String, driverPhoneNumber: String) {
        self.id = id
        self.driverName = driverName
        self.driverPhoneNumber = driverPhoneNumber
    }
}
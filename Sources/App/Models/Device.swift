import Fluent
import Vapor

final class Device: Model, Content, @unchecked Sendable {
    static let schema = "devices"
    
    @ID(custom: "device_id", generatedBy: .random)
    var id: UUID?
    
    @Field(key: "device_name")
    var deviceName: String
    
    init() { }
    
    init(id: UUID? = nil, deviceName: String) {
        self.id = id
        self.deviceName = deviceName
    }
}
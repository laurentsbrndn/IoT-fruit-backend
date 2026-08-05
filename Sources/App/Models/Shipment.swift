import Fluent
import Vapor

final class Shipment: Model, Content, @unchecked Sendable {
    static let schema = "shipments"
    
    @ID(custom: "shipment_id", generatedBy: .random)
    var id: UUID?
    
    @Parent(key: "device_id")
    var device: Device
    
    @Parent(key: "driver_id")
    var driver: Driver
    
    @Field(key: "shipment_truck_plate_number")
    var truckPlateNumber: String
    
    @Field(key: "shipment_start_date")
    var startDate: Date
    
    @OptionalField(key: "shipment_end_date")
    var endDate: Date?
    
    @Field(key: "shipment_start_latitude")
    var startLatitude: Double
    
    @Field(key: "shipment_start_longitude")
    var startLongitude: Double
    
    @OptionalField(key: "shipment_end_latitude")
    var endLatitude: Double?
    
    @OptionalField(key: "shipment_end_longitude")
    var endLongitude: Double?
    
    init() { }
    
    init(id: UUID? = nil, deviceID: UUID, driverID: UUID, truckPlateNumber: String, startDate: Date, endDate: Date? = nil, startLatitude: Double, startLongitude: Double, endLatitude: Double? = nil, endLongitude: Double? = nil) {
        self.id = id
        self.$device.id = deviceID
        self.$driver.id = driverID
        self.truckPlateNumber = truckPlateNumber
        self.startDate = startDate
        self.endDate = endDate
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
    }
}
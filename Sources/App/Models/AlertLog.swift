import Fluent
import Vapor

final class AlertLog: Model, Content, @unchecked Sendable {
    static let schema = "alert_logs"
    
    @ID(custom: "alert_log_id", generatedBy: .random)
    var id: UUID?
    
    @Parent(key: "alert_type_id")
    var alertType: AlertType
    
    @Parent(key: "shipment_id")
    var shipment: Shipment
    
    @Parent(key: "sensor_log_id")
    var sensorLog: SensorLog
    
    @Field(key: "timestamps")
    var timestamps: Date
    
    init() { }
    
    init(id: UUID? = nil, alertTypeID: UUID, shipmentID: UUID, sensorLogID: UUID, timestamps: Date) {
        self.id = id
        self.$alertType.id = alertTypeID
        self.$shipment.id = shipmentID
        self.$sensorLog.id = sensorLogID
        self.timestamps = timestamps
    }
}
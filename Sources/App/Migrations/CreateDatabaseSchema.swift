import Fluent

struct CreateDatabaseSchema: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("devices")
            .field("device_id", .uuid, .identifier(auto: false))
            .field("device_name", .string, .required)
            .create()
        
        try await database.schema("drivers")
            .field("driver_id", .uuid, .identifier(auto: false))
            .field("driver_name", .string, .required)
            .field("driver_phone_number", .string, .required)
            .create()
            
        try await database.schema("alert_types")
            .field("alert_type_id", .uuid, .identifier(auto: false))
            .field("alert_type_title", .string, .required)
            .field("alert_type_severity", .string, .required)
            .field("alert_type_description", .string)
            .create()
            
        try await database.schema("shipments")
            .field("shipment_id", .uuid, .identifier(auto: false))
            .field("device_id", .uuid, .required, .references("devices", "device_id"))
            .field("driver_id", .uuid, .required, .references("drivers", "driver_id"))
            .field("shipment_truck_plate_number", .string, .required)
            .field("shipment_start_date", .datetime, .required)
            .field("shipment_end_date", .datetime)
            .field("shipment_start_latitude", .double, .required)
            .field("shipment_start_longitude", .double, .required)
            .field("shipment_end_latitude", .double)
            .field("shipment_end_longitude", .double)
            .create()
            
        try await database.schema("sensor_logs")
            .field("sensor_log_id", .uuid, .identifier(auto: false))
            .field("shipment_id", .uuid, .required, .references("shipments", "shipment_id"))
            .field("sensor_log_temperature", .double)
            .field("sensor_log_humidity", .double)
            .field("sensor_log_latitude", .double)
            .field("sensor_log_longitude", .double)
            .field("sensor_log_battery_percentage", .double)
            .field("sensor_log_timestamps", .datetime)
            .create()
            
        try await database.schema("alert_logs")
            .field("alert_log_id", .uuid, .identifier(auto: false))
            .field("alert_type_id", .uuid, .required, .references("alert_types", "alert_type_id"))
            .field("shipment_id", .uuid, .required, .references("shipments", "shipment_id"))
            .field("sensor_log_id", .uuid, .required, .references("sensor_logs", "sensor_log_id"))
            .field("timestamps", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("alert_logs").delete()
        try await database.schema("sensor_logs").delete()
        try await database.schema("shipments").delete()
        try await database.schema("alert_types").delete()
        try await database.schema("drivers").delete()
        try await database.schema("devices").delete()
    }
}
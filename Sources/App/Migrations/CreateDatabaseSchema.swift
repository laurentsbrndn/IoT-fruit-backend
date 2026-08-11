import Fluent
import SQLKit

struct CreateDatabaseSchema: AsyncMigration {
    func prepare(on database: Database) async throws {
        
        if let sql = database as? SQLDatabase {
            try await sql.raw("CREATE EXTENSION IF NOT EXISTS timescaledb;").run()
        }
        
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
            .field("alert_type_category", .string, .required)
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
            .field("sensor_log_latitude", .array(of: .double))
            .field("sensor_log_longitude", .array(of: .double))
            .field("sensor_log_timestamps", .datetime, .required)
            .create()
            
        try await database.schema("alert_logs")
            .field("alert_log_id", .uuid, .identifier(auto: false))
            .field("alert_type_id", .uuid, .required, .references("alert_types", "alert_type_id"))
            .field("shipment_id", .uuid, .required, .references("shipments", "shipment_id"))
            .field("sensor_log_id", .uuid, .required) 
            .field("timestamps", .datetime, .required)
            .create()
            
        if let sql = database as? SQLDatabase {
            try await sql.raw("ALTER TABLE sensor_logs DROP CONSTRAINT sensor_logs_pkey CASCADE;").run()
            try await sql.raw("ALTER TABLE sensor_logs ADD PRIMARY KEY (sensor_log_id, sensor_log_timestamps);").run()
            try await sql.raw("SELECT create_hypertable('sensor_logs', 'sensor_log_timestamps');").run()
            
            try await sql.raw("ALTER TABLE alert_logs DROP CONSTRAINT alert_logs_pkey CASCADE;").run()
            try await sql.raw("ALTER TABLE alert_logs ADD PRIMARY KEY (alert_log_id, timestamps);").run()
            try await sql.raw("SELECT create_hypertable('alert_logs', 'timestamps');").run()
        }
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
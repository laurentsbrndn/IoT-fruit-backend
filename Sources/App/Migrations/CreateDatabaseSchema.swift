import Fluent

struct CreateDatabaseSchema: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("users")
            .id()
            .field("email", .string, .required)
            .field("password_hash", .string, .required)
            .field("role", .string, .required)
            .unique(on: "email")
            .create()

        try await database.schema("trucks")
            .id()
            .field("device_id", .string, .required)
            .field("truck_name", .string, .required)
            .field("plate_number", .string, .required)
            .field("status", .string, .required)
            .field("created_at", .datetime)
            .unique(on: "device_id")
            .create()
        
        try await database.schema("sensor_logs")
            .id()
            .field("truck_id", .uuid, .required, .references("trucks", "id"))
            .field("temperature", .double, .required)
            .field("humidity", .double, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("battery", .int, .required)
            .field("timestamp", .datetime, .required)
            .field("created_at", .datetime)
            .create()
        
        try await database.schema("alerts")
            .id()
            .field("truck_id", .uuid, .required, .references("trucks", "id"))
            .field("type", .string, .required)
            .field("message", .string, .required)
            .field("severity", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("alerts").delete()
        try await database.schema("sensor_logs").delete()
        try await database.schema("trucks").delete()
        try await database.schema("users").delete()
    }
}
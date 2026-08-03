import Fluent

struct CreateDatabaseSchema: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("sensor_logs")
            .id()
            .field("device_id", .string, .required)
            .field("temperature", .double, .required)
            .field("humidity", .double, .required)
            .field("latitude", .double, .required)
            .field("longitude", .double, .required)
            .field("battery", .int)
            .field("timestamp", .datetime, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("sensor_logs").delete()
    }
}
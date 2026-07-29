import Vapor
import Fluent
import FluentPostgresDriver

public func config(_ app: Application) async throws {
    
    app.databases.use(.postgres(
        hostname: "localhost",
        username: "postgres",
        password: "adonuhuy", 
        database: "fruit_shipment"
    ), as: .psql)
    
    app.migrations.add(CreateDatabaseSchema())
    app.migrations.add(SeedDataMigration())
    
    // berguna buat otomatis membuat tabel di database saat pertama kali menjalankan aplikasi.
    // try await app.autoMigrate()
    
    let mqttManager = MQTTManager(app: app)
    try mqttManager.start()

    try routes(app)
}
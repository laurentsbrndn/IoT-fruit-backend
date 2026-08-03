// LOCAL DATABASE

// import Vapor
// import Fluent
// import FluentPostgresDriver

// public func config(_ app: Application) async throws {
    
//     app.databases.use(.postgres(
//         hostname: "localhost",
//         username: "postgres",
//         password: "adonuhuy", 
//         database: "fruit_shipment"
//     ), as: .psql)
    
//     app.migrations.add(CreateDatabaseSchema())
    
//     let mqttManager = MQTTManager(app: app)
//     try mqttManager.start()

//     try routes(app)
// }

// NEON (CLOUD) DATABASE

import Vapor
import Fluent
import FluentPostgresDriver

public func config(_ app: Application) async throws {
    
    guard let databaseURL = Environment.get("DATABASE_URL") else {
        fatalError("🚨 DATABASE_URL tidak ditemukan di file .env")
    }
    
    try app.databases.use(.postgres(url: databaseURL), as: .psql)
    
    app.migrations.add(CreateDatabaseSchema())
    
    try await app.autoMigrate()
    
    let mqttManager = MQTTManager(app: app)
    try mqttManager.start()

    try routes(app)
}
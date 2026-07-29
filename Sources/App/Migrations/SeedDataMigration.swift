import Fluent
import Vapor

struct SeedDataMigration: AsyncMigration {
    func prepare(on database: Database) async throws {
        let existingTruck = try await Truck.query(on: database)
            .filter(\.$deviceID == "IoT_01")
            .first()
        
        if existingTruck == nil {
            let newTruck = Truck(
                deviceID: "IoT_01",
                truckName: "Truk Mangga Alpha",
                plateNumber: "B 1234 CD",
                status: "ACTIVE"
            )
            try await newTruck.save(on: database)
            print("Data Truk awal (IoT_01) berhasil di-seed otomatis ke database.")
        }
    }

    func revert(on database: Database) async throws {
        try await Truck.query(on: database).filter(\.$deviceID == "IoT_01").delete()
    }
}
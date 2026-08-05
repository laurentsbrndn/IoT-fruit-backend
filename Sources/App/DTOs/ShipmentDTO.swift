import Vapor

struct StartShipmentDTO: Content {
    let deviceId: String
    let driverId: String
    let truckPlateNumber: String
    let startLatitude: Double
    let startLongitude: Double
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case driverId = "driver_id"
        case truckPlateNumber = "truck_plate_number"
        case startLatitude = "start_latitude"
        case startLongitude = "start_longitude"
    }
}

struct FinishShipmentDTO: Content {
    let endLatitude: Double
    let endLongitude: Double
    
    enum CodingKeys: String, CodingKey {
        case endLatitude = "end_latitude"
        case endLongitude = "end_longitude"
    }
}
import Foundation

struct MQTTDecoder {
    static func decode(payload: Data) throws -> MQTTTelemetryDTO {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 
        return try decoder.decode(MQTTTelemetryDTO.self, from: payload)
    }
}
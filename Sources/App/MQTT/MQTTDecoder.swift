import Foundation

struct MQTTDecoder {
    static func decode(payload: Data) throws -> MQTTBatchedTelemetryDTO {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 
        return try decoder.decode(MQTTBatchedTelemetryDTO.self, from: payload)
    }
}
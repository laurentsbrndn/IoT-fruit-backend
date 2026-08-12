import Vapor

struct MQTTManagerKey: StorageKey {
    typealias Value = MQTTManager
}

extension Application {
    var telemetryService: TelemetryService {
        return TelemetryService(app: self)
    }
    
    var mqttManager: MQTTManager? {
        get {
            self.storage[MQTTManagerKey.self]
        }
        set {
            self.storage[MQTTManagerKey.self] = newValue
        }
    }
}
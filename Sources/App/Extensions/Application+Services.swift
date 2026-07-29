import Vapor

extension Application {
    var telemetryService: TelemetryService {
        return TelemetryService(app: self)
    }
}
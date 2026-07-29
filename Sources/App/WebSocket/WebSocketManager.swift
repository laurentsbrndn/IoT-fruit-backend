import Vapor

actor WebSocketManager {
    static let shared = WebSocketManager()
    private var clients: [UUID: WebSocket] = [:]
    
    func connect(_ ws: WebSocket) {
        let id = UUID()
        clients[id] = ws
        print("🔗 Klien WebSocket Terhubung: \(id)")
        
        ws.onClose.whenComplete { _ in
            Task { await self.disconnect(id) }
        }
    }
    
    func disconnect(_ id: UUID) {
        clients.removeValue(forKey: id)
        print("❌ Klien WebSocket Terputus: \(id)")
    }
    
    func broadcast(telemetry: MQTTTelemetryDTO) {
        guard let data = try? JSONEncoder().encode(telemetry),
              let jsonString = String(data: data, encoding: .utf8) else { return }
        
        for client in clients.values {
            client.send(jsonString)
        }
    }
}
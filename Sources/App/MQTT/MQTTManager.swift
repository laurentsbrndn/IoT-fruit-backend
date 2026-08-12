import Vapor
import MQTTNIO
import NIOCore
import NIOPosix

final class MQTTManager {
    let app: Application
    let subscriber: MQTTSubscriber
    var client: MQTTClient?
    
    init(app: Application) {
        self.app = app
        self.subscriber = MQTTSubscriber(app: app)
    }
    
    func start() throws {
        app.logger.notice("Mencoba terhubung ke MQTT Broker...")
        
        let configuration = MQTTConfiguration(
            target: .host("broker.hivemq.com", port: 1883),
            clientId: "VaporBackend_" + UUID().uuidString.prefix(6),
            keepAliveInterval: .seconds(60) 
        )
        
        let mqttClient = MQTTClient(
            configuration: configuration,
            eventLoopGroup: app.eventLoopGroup
        )
        self.client = mqttClient
        
        Task {
            while !Task.isCancelled {
                do {
                    app.logger.info("Mencoba terhubung ke MQTT Broker...")
                    try await mqttClient.connect()

                    app.logger.info("✅ Berhasil terhubung ke MQTT Broker!")
                    app.logger.info("🔄 Mencoba subscribe ke topic: \(MQTTTopics.telemetry)")

                    let subscription = MQTTSubscription(
                        topicFilter: MQTTTopics.telemetry,
                        qos: .atLeastOnce
                    )

                    let subscribeResult = try await mqttClient.subscribe(to: [subscription])

                    app.logger.info("✅ BERHASIL SUBSCRIBE")
                    app.logger.info("📡 Topic: \(MQTTTopics.telemetry)")
                    app.logger.info("📡 Result: \(String(describing: subscribeResult))")

                    app.logger.info("👂 Mulai menunggu MQTT message...")
                    
                    for await message in mqttClient.messages {
                        app.logger.info("🚨 MQTT MESSAGE MASUK!")
                        app.logger.info("Topic: \(message.topic)")
                        let topic = message.topic
                        
                        let data: Data
                        switch message.payload {
                        case .empty:
                            data = Data()
                        case .bytes(var buffer):
                            data = buffer.readData(length: buffer.readableBytes) ?? Data()
                        case .string(let string, _):
                            data = Data(string.utf8)
                        }
                        
                        self.subscriber.handleIncomingMessage(topic: topic, payload: data)
                    }
                    
                    app.logger.warning("⚠️ Loop MQTT messages terputus, mencoba auto-reconnect dalam 5 detik...")
                    
                } catch {
                    app.logger.error("❌ Gagal koneksi/subscribe ke MQTT Broker: \(error). Reconnect dalam 5 detik...")
                }
                
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }
    
    func stop() {
        Task {
            try? await client?.disconnect()
        }
    }
}
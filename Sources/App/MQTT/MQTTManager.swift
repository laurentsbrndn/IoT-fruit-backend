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
        app.logger.info("Mencoba terhubung ke MQTT Broker...")
        
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
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
            do {
                try await mqttClient.connect()
                app.logger.info("✅ Berhasil terhubung ke MQTT Broker!")
                
                let subscription = MQTTSubscription(topicFilter: MQTTTopics.telemetry, qos: .atLeastOnce)
                let subscribeResult = try await mqttClient.subscribe(to: [subscription])
                app.logger.info("📡 Berhasil Subscribe ke topik: \(MQTTTopics.telemetry) (Result: \(String(describing: subscribeResult)))")
                
                for await message in mqttClient.messages {
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
                
            } catch {
                app.logger.error("❌ Gagal koneksi/subscribe ke MQTT Broker: \(error)")
            }
        }
    }
    
    func stop() {
        Task {
            try? await client?.disconnect()
        }
    }
}
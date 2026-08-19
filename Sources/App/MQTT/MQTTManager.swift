import MQTTNIO
import NIOCore
import NIOPosix
import Vapor

final class MQTTManager {
    let app: Application
    let subscriber: MQTTSubscriber
    var client: MQTTClient?

    init(app: Application) {
        self.app = app
        self.subscriber = MQTTSubscriber(app: app)
    }

    func start() throws {
        let host = Environment.get("MQTT_HOST") ?? "dfc14af1.ala.asia-southeast1.emqxsl.com"
        let port = Int(Environment.get("MQTT_PORT") ?? "8883") ?? 8883
        let username = Environment.get("MQTT_USER") ?? "iot_tracker"
        let password = Environment.get("MQTT_PASSWORD") ?? "884fd935-7965-4c19-8d59-973fc5fa11b6"
        let useTLS = (Environment.get("MQTT_TLS") ?? "true").lowercased() == "true" || port == 8883

        app.logger.notice("Mencoba terhubung ke MQTT Broker: \(host):\(port) (TLS: \(useTLS))...")

        let configuration = MQTTConfiguration(
            target: .host(host, port: port),
            tls: useTLS ? .default(for: app.eventLoopGroup) : nil,
            clientId: "vapor_backend_123tBab2",
            credentials: .init(username: username, password: password),
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

                app.logger.notice("✅ Berhasil terhubung ke MQTT Broker!")

                app.logger.notice("🔄 Mencoba subscribe ke topic: \(MQTTTopics.telemetry)")

                let subscription = MQTTSubscription(
                    topicFilter: MQTTTopics.telemetry,
                    qos: .atLeastOnce
                )

                let subscribeResult = try await mqttClient.subscribe(to: [subscription])

                app.logger.notice("✅ BERHASIL SUBSCRIBE")
                app.logger.notice("📡 Topic: \(MQTTTopics.telemetry)")
                app.logger.notice("📡 Result: \(String(describing: subscribeResult))")

                app.logger.notice("👂 Mulai menunggu MQTT message...")

                for await message in mqttClient.messages {

                    app.logger.notice("🚨 MQTT MESSAGE MASUK!")
                    app.logger.notice("Topic: \(message.topic)")
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

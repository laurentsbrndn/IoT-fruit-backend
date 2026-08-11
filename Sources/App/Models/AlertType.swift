import Fluent
import Vapor

final class AlertType: Model, Content, @unchecked Sendable {
    static let schema = "alert_types"
    
    @ID(custom: "alert_type_id", generatedBy: .random)
    var id: UUID?
    
    @Field(key: "alert_type_title")
    var title: String
    
    @Field(key: "alert_type_severity")
    var severity: String
    
    @Field(key: "alert_type_category")
    var category: String
    
    @OptionalField(key: "alert_type_description")
    var description: String?
    
    init() { }
    
    init(id: UUID? = nil, title: String, severity: String, category: String, description: String? = nil) {
        self.id = id
        self.title = title
        self.severity = severity
        self.category = category
        self.description = description
    }
}
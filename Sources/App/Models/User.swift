import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "email")
    var email: String
    
    @Field(key: "password_hash")
    var passwordHash: String
    
    @Field(key: "role")
    var role: String
    
    init() { }
    
    init(id: UUID? = nil, email: String, passwordHash: String, role: String) {
        self.id = id
        self.email = email
        self.passwordHash = passwordHash
        self.role = role
    }
}
class User: Decodable {
    
    private let id: Int
    private let email: String
    private(set) var nickname: String
    

    init(id: Int, email: String, nickname: String) {
        self.id = id
        self.email = email
        self.nickname = nickname
    }
}

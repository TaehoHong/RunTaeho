import Foundation

class ShoeApiService {
    static let shared = ShoeApiService()
    private let userStateManager = UserStateManager.shared
    private let httpClient = HTTPClient.shared
    
    private init() {}
    
    func fetchShoes() async throws -> CursorResult<Shoe> {
        return try await fetchShoesCursor(cursor: nil, size: 100)
    }
    
    private func fetchShoesCursor(cursor: Int? = nil, size: Int = 10) async throws -> CursorResult<Shoe> {
        
        var params: [String: String] = ["size": "10"]
        if let cursor = cursor {
            params["cursor"] = String(cursor)
        }
        
         return try await httpClient.get(
             urlPath: GET_SHOE,
             headers: ["Authorization": "Bearer \(userStateManager.authToken!)"],
             requestParam: RequestParam(params: params),
             responseType: CursorResult<Shoe>.self
         )
    }
    
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe {
         let response = try await httpClient.post(
             urlPath: CREATE_SHOE,
             body: addShoeDto,
             headers: ["Authorization": "Bearer \(userStateManager.authToken!)"],
             responseType: Shoe.self
         )
         return response
    }
    
    func updateShoe(_ shoe: Shoe) async throws -> Shoe {
        // TODO: API 구현
        // let response = try await httpClient.request(
        //     path: "\(APIPath.shoes.rawValue)/\(shoe.id)",
        //     method: .PUT,
        //     body: shoe,
        //     responseType: Shoe.self
        // )
        // return response
        
        return shoe
    }
}

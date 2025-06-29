import Foundation

class ShoeApiService {
    static let shared = ShoeApiService()
    private let userStateManager = UserStateManager.shared
    private let httpClient = HTTPClient.shared
    
    private init() {}
    
    func fetchShoesCursor(cursor: Int? = nil, size: Int = 10) async throws -> CursorResult<Shoe> {
        
        var params: [String: String] = ["size": String(size)]
        if let cursor = cursor {
            params["cursor"] = String(cursor)
        }
        
        guard let authToken = userStateManager.authToken else {
            throw NetworkError.unauthorized
        }
        
        return try await httpClient.get(
            urlPath: APIPath.Shoe.list,
            headers: ["Authorization": "Bearer \(authToken)"],
            requestParam: RequestParam(params: params),
            responseType: CursorResult<Shoe>.self
        )
    }
    
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe {
        guard let authToken = userStateManager.authToken else {
            throw NetworkError.unauthorized
        }
        
        let response = try await httpClient.post(
            urlPath: APIPath.Shoe.create,
            body: addShoeDto,
            headers: ["Authorization": "Bearer \(authToken)"],
            responseType: Shoe.self
        )
        return response
    }
    
    func patchShoe(_ shoe: PatchShoeDto) async throws -> Shoe {
        
        guard let authToken = userStateManager.authToken else {
            throw NetworkError.unauthorized
        }
        
        let response = try await httpClient.patch(
            urlPath: APIPath.Shoe.patch(shoe.id),
            body: shoe,
            headers: ["Authorization": "Bearer \(authToken)"],
            responseType: Shoe.self
        )
        return response
    }
    
}

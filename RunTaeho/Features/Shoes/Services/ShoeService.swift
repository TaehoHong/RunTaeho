import Foundation

class ShoeService {
    
    public static let shared = ShoeService()
    private let shoeApiService = ShoeApiService.shared
    
    private init() {}
    
    func fetchShoes(cursor: Int?=nil) async throws -> CursorResult<Shoe> {
        
        return try await shoeApiService.fetchShoes(cursor: cursor)
    }
    
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe {
        return try await shoeApiService.addShoe(addShoeDto)
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
    
    func deleteShoe(id: Int) async throws {
        // TODO: API 구현
        // try await httpClient.request(
        //     path: "\(APIPath.shoes.rawValue)/\(id)",
        //     method: .DELETE
        // )
    }
    
    func setActiveShoe(id: Int) async throws {
        // TODO: API 구현
        // try await httpClient.request(
        //     path: "\(APIPath.shoes.rawValue)/\(id)/activate",
        //     method: .POST
        // )
    }
}

import Foundation

class ShoeService {
    
    public static let shared = ShoeService()
    private let shoeApiService = ShoeApiService.shared
    
    private init() {}
    
    func fetchShoes(cursor: Int?=nil, isEnabled: Bool?=nil) async throws -> CursorResult<Shoe> {
        
        return try await shoeApiService.fetchShoesCursor(cursor: cursor, isEnabled: isEnabled)
    }
    
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe {
        return try await shoeApiService.addShoe(addShoeDto)
    }
    
    func achieveShoe(id: Int) async throws {
        
        try await shoeApiService.patchShoe(PatchShoeDto(id: id, isEnabled: false))
        
    }
    
    func deleteShoe(id: Int) async throws {
        try await shoeApiService.patchShoe(PatchShoeDto(id: id, isDeleted: true))
    }
    
    func setActiveShoe(id: Int) async throws {
        
        try await shoeApiService.patchShoe(PatchShoeDto(id: id, isEnabled: true))
    }
    
    func updateShoe(_ patchShoeDto: PatchShoeDto) async throws -> Shoe {
        return try await shoeApiService.patchShoe(patchShoeDto)
    }
}

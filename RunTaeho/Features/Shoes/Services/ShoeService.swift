import Foundation

protocol ShoeServiceProtocol {
    func fetchShoes() async throws -> [Shoe]
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe
    func updateShoe(_ shoe: Shoe) async throws -> Shoe
    func deleteShoe(id: Int) async throws
    func setActiveShoe(id: Int) async throws
}

class ShoeService: ShoeServiceProtocol {
    private let httpClient = HTTPClient.shared
    
    func fetchShoes() async throws -> [Shoe] {
        // TODO: API 구현
        // let response = try await httpClient.request(
        //     path: APIPath.shoes.rawValue,
        //     method: .GET,
        //     responseType: [Shoe].self
        // )
        // return response
        
        // 임시 더미 데이터
        return []
    }
    
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe {
        // TODO: API 구현
        // let response = try await httpClient.request(
        //     path: APIPath.shoes.rawValue,
        //     method: .POST,
        //     body: shoe,
        //     responseType: Shoe.self
        // )
        // return response
        
        return Shoe(
            id: 0,
            brand: addShoeDto.brand,
            model: addShoeDto.model,
            totalDistance: 0,
            targetDistance: addShoeDto.targetDistance,
            isMain: addShoeDto.isMain,
            createdAt: Date()
        )
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

// 더미 서비스 (개발용)
class ShoesDummyService: ShoeServiceProtocol {
    private var shoes: [Shoe] = [
        Shoe(
            id: 1,
            brand: "나이키",
            model: "에어 줌 페가수스 40",
            totalDistance: 245.7,
            isMain: true,
            createdAt: Date().addingTimeInterval(-30*24*60*60)
        ),
        Shoe(
            id: 2,
            brand: "아디다스",
            model: "울트라부스트 22",
            totalDistance: 123.4,
            isMain: false,
            createdAt: Date().addingTimeInterval(-60*24*60*60)
        )
    ]
    
    func fetchShoes() async throws -> [Shoe] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5초 딜레이
        return shoes
    }
    
    func addShoe(_ addShoeDto: AddShoeDto) async throws -> Shoe {
        return Shoe(
            id: 0,
            brand: addShoeDto.brand,
            model: addShoeDto.model,
            totalDistance: 0,
            targetDistance: addShoeDto.targetDistance,
            isMain: addShoeDto.isMain,
            createdAt: Date()
        )
    }
    
    func updateShoe(_ shoe: Shoe) async throws -> Shoe {
        if let index = shoes.firstIndex(where: { $0.id == shoe.id }) {
            shoes[index] = shoe
        }
        return shoe
    }
    
    func deleteShoe(id: Int) async throws {
        shoes.removeAll(where: { $0.id == id })
    }
    
    func setActiveShoe(id: Int) async throws {
        for index in shoes.indices {
            shoes[index].isMain = shoes[index].id == id
        }
    }
}

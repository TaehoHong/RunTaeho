import Foundation

enum NetworkError: Error, LocalizedError {
    case badURL
    case noData
    case decodingError(Error)
    case encodingError(Error)
    case httpError(statusCode: Int, data: Data?)
    case networkError(Error)
    case unauthorized
    case notFound
    case serverError(statusCode: Int)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Decoding failed: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding failed: \(error.localizedDescription)"
        case .httpError(let statusCode, _):
            return "HTTP Error: \(statusCode)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized - Please login again"
        case .notFound:
            return "Resource not found"
        case .serverError(let statusCode):
            return "Server Error: \(statusCode)"
        case .invalidResponse:
            return "Invalid response from server"
        }
    }
}

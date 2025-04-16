import Foundation

enum NetworkError: Error {
    case badURL
    case noData
    case decodingError(Error)
}

class HTTPClient {

    static let shared = HTTPClient()
    private init() { }

    
    func get<T: Decodable>(url: String, requestParam: RequestParam?, responseType: T.Type, completion: @escaping(Result<T, Error>) -> Void) {

        var urlString = url

        if let params = requestParam?.params, !params.isEmpty {
            urlString += "?"
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += queryString
        }

        guard let requestURL = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL))
            return
        }
        
        print("urlString: \(urlString)")
        var request: URLRequest = URLRequest(url: requestURL) 
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error occurred: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Response status code: \(httpResponse.statusCode)")
            } else {
                print("Received response is not an HTTPURLResponse")
            }
            
            guard let data = data else {
                print("No data received from the request")
                completion(.failure(NetworkError.noData))
                return
            }
            
            if let dataString = String(data: data, encoding: .utf8) {
                print("Response data: \(dataString)")
            } else {
                print("Failed to convert response data to a String")
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch let decodingError {
                print("Decoding error: \(decodingError.localizedDescription)")
                completion(.failure(NetworkError.decodingError(decodingError)))
            }
        }
        task.resume()
    }
}

struct RequestParam {
    var params: [String: String] = [:]
}

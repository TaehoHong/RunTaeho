import Foundation

enum NetworkError: Error {
    case badURL
    case noData
    case decodingError(Error)
}

class HTTPClient {

    static let shared = HTTPClient()
    private init() { }
    
    // MARK: - Logging Methods
    #if DEBUG
    private func logRequest(_ request: URLRequest, startTime: Date) {
        print("\n🚀 [HTTP REQUEST] ===========================================")
        print("📅 Timestamp: \(ISO8601DateFormatter().string(from: startTime))")
        print("🌐 URL: \(request.url?.absoluteString ?? "Unknown")")
        print("📋 Method: \(request.httpMethod ?? "Unknown")")
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📝 Headers:")
            headers.forEach { key, value in
                print("   \(key): \(value)")
            }
        }
        
        if let httpBody = request.httpBody, 
           let bodyString = String(data: httpBody, encoding: .utf8) {
            print("📦 Body: \(bodyString)")
        }
        
        if let httpBodyStream = request.httpBodyStream {
            print("📦 Body Stream: Present (\(httpBodyStream))")
        }
        
        print("🏷️ Cache Policy: \(request.cachePolicy.rawValue)")
        print("⏱️ Timeout: \(request.timeoutInterval)s")
        print("=========================================================\n")
    }
    
    private func logResponse(_ response: URLResponse?, data: Data?, error: Error?, startTime: Date) {
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        print("\n📨 [HTTP RESPONSE] =========================================")
        print("📅 Timestamp: \(ISO8601DateFormatter().string(from: endTime))")
        print("⏱️ Duration: \(String(format: "%.3f", duration))s")
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusEmoji = httpResponse.statusCode < 300 ? "✅" : httpResponse.statusCode < 400 ? "⚠️" : "❌"
            print("\(statusEmoji) Status Code: \(httpResponse.statusCode)")
            print("🌐 URL: \(httpResponse.url?.absoluteString ?? "Unknown")")
            
            if !httpResponse.allHeaderFields.isEmpty {
                print("📝 Response Headers:")
                httpResponse.allHeaderFields.forEach { key, value in
                    print("   \(key): \(value)")
                }
            }
        }
        
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                if !nsError.userInfo.isEmpty {
                    print("   UserInfo: \(nsError.userInfo)")
                }
            }
        }
        
        if let data = data {
            print("📊 Data Size: \(data.count) bytes")
            
            if let dataString = String(data: data, encoding: .utf8) {
                if dataString.count > 1000 {
                    print("📄 Response Data (truncated):")
                    print("\(String(dataString.prefix(1000)))...")
                    print("   [Full response size: \(dataString.count) characters]")
                } else {
                    print("📄 Response Data: \(dataString)")
                }
            } else {
                print("📄 Response Data: [Unable to convert to string - Binary data]")
            }
        } else {
            print("📄 Response Data: No data received")
        }
        
        print("=========================================================\n")
    }
    #endif

    
    func get<T: Decodable>(urlPath: String, headers: [String: String]? = nil, requestParam: RequestParam? = nil, responseType: T.Type, completion: @escaping(Result<T, Error>) -> Void) {
        let startTime = Date()
        
        var urlString = URL.makeForStringEndpoint(urlPath)

        if let params = requestParam?.params, !params.isEmpty {
            urlString += "?"
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += queryString
        }

        guard let requestURL = URL(string: urlString) else {
            #if DEBUG
            print("❌ [HTTP ERROR] Invalid URL: \(urlString)")
            #endif
            completion(.failure(NetworkError.badURL))
            return
        }

        var request: URLRequest = URLRequest(url: requestURL) 
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { (key: String, value: String) in
            request.addValue(value, forHTTPHeaderField: key)       
        }

        #if DEBUG
        logRequest(request, startTime: startTime)
        #endif

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            #if DEBUG
            self.logResponse(response, data: data, error: error, startTime: startTime)
            #endif
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
            } catch let decodingError {
                completion(.failure(NetworkError.decodingError(decodingError)))
            }
        }
        task.resume()
    }
}

struct RequestParam {
    var params: [String: String] = [:]
}

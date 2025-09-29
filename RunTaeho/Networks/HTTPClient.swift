import Foundation

class HTTPClient {
    
    static let shared = HTTPClient()
    private let session: URLSession
    private var interceptors: [RequestInterceptor] = []
    private var configuration: RequestConfiguration
    
    private init(session: URLSession = .shared, configuration: RequestConfiguration = .default) {
        self.session = session
        self.configuration = configuration
    }
    
    // MARK: - Configuration Methods
    func setConfiguration(_ configuration: RequestConfiguration) {
        self.configuration = configuration
    }
    
    func addInterceptor(_ interceptor: RequestInterceptor) {
        interceptors.append(interceptor)
    }
    
    func removeAllInterceptors() {
        interceptors.removeAll()
    }
    
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
    
    // MARK: - Response Validation
    private func validateResponse(_ response: URLResponse?, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }
    
    // MARK: - Core Request Method (통합된 버전)
    private func performRequest<T>(
        method: String,
        urlPath: String,
        headers: [String: String]? = nil,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) where T: Decodable {
        let startTime = Date()
        
        // Build URL with query parameters
        var urlString = URL.makeForStringEndpoint(urlPath)
        if let queryParams = queryParams, !queryParams.isEmpty {
            urlString += "?"
            let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += queryString
        }
        
        guard let requestURL = URL(string: urlString) else {
            #if DEBUG
            print("❌ [HTTP ERROR] Invalid URL: \(urlString)")
            #endif
            completion(.failure(NetworkError.badURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.timeoutInterval = configuration.timeoutInterval
        request.cachePolicy = configuration.cachePolicy
        request.allowsCellularAccess = configuration.allowsCellularAccess
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Apply interceptors
        interceptors.forEach { interceptor in
            interceptor.intercept(&request)
        }
        
        // Add body
        request.httpBody = body
        
        #if DEBUG
        logRequest(request, startTime: startTime)
        #endif
        
        // Perform request
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            #if DEBUG
            self?.logResponse(response, data: data, error: error, startTime: startTime)
            #endif
            
            if let error = error {
                completion(.failure(NetworkError.networkError(error)))
                return
            }
            
            do {
                try self?.validateResponse(response, data: data)
                
                guard let data = data else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                let decodedResponse = try JSONDecoder().decode(responseType, from: data)
                completion(.success(decodedResponse))
                
            } catch {
                if error is NetworkError {
                    completion(.failure(error))
                } else {
                    completion(.failure(NetworkError.decodingError(error)))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Helper method for Void responses
    private func performRequestVoid(
        method: String,
        urlPath: String,
        headers: [String: String]? = nil,
        body: Data? = nil,
        queryParams: [String: String]? = nil,
        completion: @escaping(Result<Void, Error>) -> Void
    ) {
        let startTime = Date()
        
        // Build URL with query parameters
        var urlString = URL.makeForStringEndpoint(urlPath)
        if let queryParams = queryParams, !queryParams.isEmpty {
            urlString += "?"
            let queryString = queryParams.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += queryString
        }
        
        guard let requestURL = URL(string: urlString) else {
            #if DEBUG
            print("❌ [HTTP ERROR] Invalid URL: \(urlString)")
            #endif
            completion(.failure(NetworkError.badURL))
            return
        }
        
        // Create request
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.timeoutInterval = configuration.timeoutInterval
        request.cachePolicy = configuration.cachePolicy
        request.allowsCellularAccess = configuration.allowsCellularAccess
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Apply interceptors
        interceptors.forEach { interceptor in
            interceptor.intercept(&request)
        }
        
        // Add body
        request.httpBody = body
        
        #if DEBUG
        logRequest(request, startTime: startTime)
        #endif
        
        // Perform request
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            #if DEBUG
            self?.logResponse(response, data: data, error: error, startTime: startTime)
            #endif
            
            if let error = error {
                completion(.failure(NetworkError.networkError(error)))
                return
            }
            
            do {
                try self?.validateResponse(response, data: data)
                // For void responses, we don't need to decode anything
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Public HTTP Methods
    func get<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        requestParam: RequestParam? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        performRequest(
            method: "GET",
            urlPath: urlPath,
            headers: headers,
            queryParams: requestParam?.params,
            responseType: responseType,
            completion: completion
        )
    }
    
    func post<T: Decodable, U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        do {
            let bodyData = try JSONEncoder().encode(body)
            performRequest(
                method: "POST",
                urlPath: urlPath,
                headers: headers,
                body: bodyData,
                responseType: responseType,
                completion: completion
            )
        } catch {
            completion(.failure(NetworkError.encodingError(error)))
        }
    }
    
    func post<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        performRequest(
            method: "POST",
            urlPath: urlPath,
            headers: headers,
            body: nil,
            responseType: responseType,
            completion: completion
        )
    }
    
    // POST method without response (Void)
    func post<U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
        completion: @escaping(Result<Void, Error>) -> Void
    ) {
        do {
            let bodyData = try JSONEncoder().encode(body)
            performRequestVoid(
                method: "POST",
                urlPath: urlPath,
                headers: headers,
                body: bodyData,
                completion: completion
            )
        } catch {
            completion(.failure(NetworkError.encodingError(error)))
        }
    }
    
    // PUT method
    func put<T: Decodable, U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        do {
            let bodyData = try JSONEncoder().encode(body)
            performRequest(
                method: "PUT",
                urlPath: urlPath,
                headers: headers,
                body: bodyData,
                responseType: responseType,
                completion: completion
            )
        } catch {
            completion(.failure(NetworkError.encodingError(error)))
        }
    }
    
    // PUT method without Response
    func put<U: Encodable>(
        urlPath: String,
        body: U? = nil,
        headers: [String: String]? = nil,
        completion: @escaping(Result<Void, Error>) -> Void
    ) {
        do {
            let bodyData = body != nil ? try JSONEncoder().encode(body) : nil
            performRequestVoid(
                method: "PUT",
                urlPath: urlPath,
                headers: headers,
                body: bodyData,
                completion: completion
            )
        } catch {
            completion(.failure(NetworkError.encodingError(error)))
        }
    }
    
    // DELETE method
    func delete<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        performRequest(
            method: "DELETE",
            urlPath: urlPath,
            headers: headers,
            responseType: responseType,
            completion: completion
        )
    }
    
    // PATCH method
    func patch<T: Decodable, U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        do {
            let bodyData = try JSONEncoder().encode(body)
            performRequest(
                method: "PATCH",
                urlPath: urlPath,
                headers: headers,
                body: bodyData,
                responseType: responseType,
                completion: completion
            )
        } catch {
            completion(.failure(NetworkError.encodingError(error)))
        }
    }
    
    // PATCH method without body
    func patch<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        responseType: T.Type,
        completion: @escaping(Result<T, Error>) -> Void
    ) {
        performRequest(
            method: "PATCH",
            urlPath: urlPath,
            headers: headers,
            body: nil,
            responseType: responseType,
            completion: completion
        )
    }
}

// MARK: - Async/Await Support
@available(iOS 13.0, *)
extension HTTPClient {
    
    // MARK: - Generic async wrapper
    private func performAsync<T: Decodable>(
        _ operation: @escaping (@escaping (Result<T, Error>) -> Void) -> Void
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            operation { result in
                continuation.resume(with: result)
            }
        }
    }
    
    private func performAsyncVoid(
        _ operation: @escaping (@escaping (Result<Void, Error>) -> Void) -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            operation { result in
                continuation.resume(with: result)
            }
        }
    }
    
    func get<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        requestParam: RequestParam? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.get(urlPath: urlPath, headers: headers, requestParam: requestParam, responseType: responseType, completion: completion)
        }
    }
    
    func post<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.post(urlPath: urlPath, headers: headers, responseType: responseType, completion: completion)
        }
    }
    
    func post<T: Decodable, U: Encodable>(
        urlPath: String,
        body: U? = nil,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.post(urlPath: urlPath, body: body, headers: headers, responseType: responseType, completion: completion)
        }
    }
    
    func post<U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil
    ) async throws {
        try await performAsyncVoid { completion in
            self.post(urlPath: urlPath, body: body, headers: headers, completion: completion)
        }
    }
    
    func put<T: Decodable, U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.put(urlPath: urlPath, body: body, headers: headers, responseType: responseType, completion: completion)
        }
    }
    
    func put<U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
    ) async throws {
        try await performAsyncVoid { completion in
            self.put(urlPath: urlPath, body: body, headers: headers, completion: completion)
        }
    }
    
    func delete<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.delete(urlPath: urlPath, headers: headers, responseType: responseType, completion: completion)
        }
    }
    
    func patch<T: Decodable, U: Encodable>(
        urlPath: String,
        body: U,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.patch(urlPath: urlPath, body: body, headers: headers, responseType: responseType, completion: completion)
        }
    }
    
    func patch<T: Decodable>(
        urlPath: String,
        headers: [String: String]? = nil,
        responseType: T.Type
    ) async throws -> T {
        try await performAsync { completion in
            self.patch(urlPath: urlPath, headers: headers, responseType: responseType, completion: completion)
        }
    }
}

struct RequestParam {
    var params: [String: String] = [:]
}

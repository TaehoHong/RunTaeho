import Foundation
import UIKit

// MARK: - Auth Interceptor Example
class AuthInterceptor: RequestInterceptor {
    private var accessToken: String? {
        // TODO: TokenManager나 UserDefaults에서 토큰을 가져오는 로직 구현
        // return TokenManager.shared.accessToken
        return nil
    }
    
    func intercept(_ request: inout URLRequest) {
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
}

// MARK: - Common Headers Interceptor
class CommonHeadersInterceptor: RequestInterceptor {
    private let headers: [String: String]
    
    init(headers: [String: String] = [:]) {
        self.headers = headers
    }
    
    func intercept(_ request: inout URLRequest) {
        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}

// MARK: - Device Info Interceptor
class DeviceInfoInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) {
        request.setValue(UIDevice.current.systemVersion, forHTTPHeaderField: "X-iOS-Version")
        request.setValue(Bundle.main.bundleIdentifier ?? "Unknown", forHTTPHeaderField: "X-App-Bundle-ID")
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            request.setValue(version, forHTTPHeaderField: "X-App-Version")
        }
    }
}

// MARK: - Logging Interceptor (Alternative to built-in logging)
class LoggingInterceptor: RequestInterceptor {
    func intercept(_ request: inout URLRequest) {
        print("🔍 [Interceptor] Request: \(request.httpMethod ?? "Unknown") \(request.url?.absoluteString ?? "Unknown URL")")
    }
}

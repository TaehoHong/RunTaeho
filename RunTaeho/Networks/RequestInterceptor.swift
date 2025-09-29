import Foundation

protocol RequestInterceptor {
    func intercept(_ request: inout URLRequest)
}

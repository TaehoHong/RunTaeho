import Foundation
import SwiftUI

// MARK: - 전역 사용자 상태 관리자
class UserStateManager: ObservableObject {
    
    // MARK: - Singleton Instance
    static let shared = UserStateManager()
    
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var authToken: String?
    @Published var refreshToken: String?
    
    // MARK: - User Preferences
    @Published var userPreferences: UserPreferences = UserPreferences()
    
    // MARK: - App State
    @Published var appLaunchCount: Int = 0
    @Published var lastAppVersion: String?
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    private let keychain = KeychainManager()
    
    // MARK: - Keys
    private enum Keys {
        static let currentUser = "currentUser"
        static let isLoggedIn = "isLoggedIn"
        static let authToken = "authToken"
        static let refreshToken = "refreshToken"
        static let userPreferences = "userPreferences"
        static let appLaunchCount = "appLaunchCount"
        static let lastAppVersion = "lastAppVersion"
    }
    
    // MARK: - Initialization
    private init() {
        // init에서 바로 상태를 로드하지 않고 비동기로 처리
        Task { @MainActor in
            loadUserState()
            incrementAppLaunchCount()
        }
    }
    
    // MARK: - Public Methods
    
    /// 사용자 로그인
    func login(user: User, authToken: String, refreshToken: String? = nil) {
        // 다음 런루프에서 실행하여 뷰 업데이트 사이클 충돌 방지
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            var updatedUser = user
            updatedUser.updateLastLogin()
            
            self.currentUser = updatedUser
            self.authToken = authToken
            self.refreshToken = refreshToken
            self.isLoggedIn = true
            
            self.saveUserState()
        }
    }
    
    /// 사용자 로그아웃
    func logout() {
        // 다음 런루프에서 실행하여 뷰 업데이트 사이클 충돌 방지
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.currentUser = nil
            self.authToken = nil
            self.refreshToken = nil
            self.isLoggedIn = false
            
            self.clearUserState()
        }
    }
    
    /// 사용자 프로필 업데이트
    func updateUserProfile(nickname: String? = nil, profileImageURL: String? = nil) {
        guard var user = currentUser else { return }
        
        user.updateProfile(nickname: nickname, profileImageURL: profileImageURL)
        currentUser = user
        saveUserState()
    }
    
    // MARK: UserAccount
    func getUserAccounts() -> [UserAccount] {
        return currentUser?.userAccounts ?? []
    }
    
    func disconnectUserAccount(provider: AuthProvider) {
        guard var user = currentUser else { return }
        
        // 해당 provider의 계정 인덱스 찾기
        if let index = user.userAccounts.firstIndex(where: { $0.provider == provider }) {
            // 해당 계정의 연결 해제 - 새 인스턴스로 교체
            user.userAccounts[index] = user.userAccounts[index].disconnect()
            
            // 변경된 user를 다시 저장
            currentUser = user
            saveUserState()
        }
    }
    
    // MARK: Point
    func getPoint() -> Int {
        return currentUser?.totalPoints ?? 0
    }
    
    /// 포인트 추가
    func addPoints(_ points: Int) {
        guard var user = currentUser else { return }
        
        user.addPoints(points)
        currentUser = user
        saveUserState()
    }
    
    /// 사용자 환경설정 업데이트
    func updatePreferences(_ preferences: UserPreferences) {
        self.userPreferences = preferences
        saveUserPreferences()
    }
    
    /// 토큰 업데이트
    func updateTokens(authToken: String, refreshToken: String? = nil) {
        self.authToken = authToken
        if let refreshToken = refreshToken {
            self.refreshToken = refreshToken
        }
        saveTokensToKeychain()
    }
    
    /// 사용자 계정 추가
    func addUserAccount(_ account: UserAccount) {
        guard var user = currentUser else { return }
        
        user.addUserAccount(account)
        currentUser = user
        saveUserState()
    }
    
    /// 사용자 계정 제거
    func removeUserAccount(provider: AuthProvider) {
        guard var user = currentUser else { return }
        
        user.removeUserAccount(provider: provider)
        currentUser = user
        saveUserState()
    }
    
    /// 사용자 닉네임 업데이트
    func updateNickname(_ nickname: String) {
        guard var user = currentUser else { return }
        
        user.nickname = nickname
        currentUser = user
        saveUserState()
    }
    
    /// 사용자 레벨 업데이트
    func updateLevel(_ level: Int) {
        guard var user = currentUser else { return }
        
        user.level = level
        currentUser = user
        saveUserState()
    }
    
    /// 앱 상태 초기화 (개발/디버그용)
    func resetAppState() {
        logout()
        userPreferences = UserPreferences()
        appLaunchCount = 0
        lastAppVersion = nil
        
        // UserDefaults 클리어
        let keysToRemove = [
            Keys.currentUser,
            Keys.isLoggedIn, 
            Keys.userPreferences,
            Keys.appLaunchCount,
            Keys.lastAppVersion
        ]
        
        keysToRemove.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
    
    // MARK: - Private Methods
    
    /// 사용자 상태 로드
    private func loadUserState() {
        // 사용자 정보 로드
        if let userData = userDefaults.data(forKey: Keys.currentUser),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
        }
        
        // 로그인 상태 로드
        self.isLoggedIn = userDefaults.bool(forKey: Keys.isLoggedIn)
        
        // 토큰 로드 (Keychain에서)
        loadTokensFromKeychain()
        
        // 사용자 환경설정 로드
        loadUserPreferences()
        
        // 앱 실행 정보 로드
        self.appLaunchCount = userDefaults.integer(forKey: Keys.appLaunchCount)
        self.lastAppVersion = userDefaults.string(forKey: Keys.lastAppVersion)
    }
    
    /// 사용자 상태 저장
    private func saveUserState() {
        // 사용자 정보 저장
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            userDefaults.set(userData, forKey: Keys.currentUser)
        }
        
        // 로그인 상태 저장
        userDefaults.set(isLoggedIn, forKey: Keys.isLoggedIn)
        
        // 토큰 저장 (Keychain에)
        saveTokensToKeychain()
    }
    
    /// 사용자 상태 클리어
    private func clearUserState() {
        userDefaults.removeObject(forKey: Keys.currentUser)
        userDefaults.set(false, forKey: Keys.isLoggedIn)
        
        // Keychain에서 토큰 삭제
        keychain.delete(key: Keys.authToken)
        keychain.delete(key: Keys.refreshToken)
    }
    
    /// 토큰을 Keychain에서 로드
    private func loadTokensFromKeychain() {
        self.authToken = keychain.load(key: Keys.authToken)
        self.refreshToken = keychain.load(key: Keys.refreshToken)
    }
    
    /// 토큰을 Keychain에 저장
    private func saveTokensToKeychain() {
        if let authToken = authToken {
            keychain.save(key: Keys.authToken, value: authToken)
        }
        if let refreshToken = refreshToken {
            keychain.save(key: Keys.refreshToken, value: refreshToken)
        }
    }
    
    /// 사용자 환경설정 로드
    private func loadUserPreferences() {
        if let preferencesData = userDefaults.data(forKey: Keys.userPreferences),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: preferencesData) {
            self.userPreferences = preferences
        }
    }
    
    /// 사용자 환경설정 저장
    private func saveUserPreferences() {
        if let preferencesData = try? JSONEncoder().encode(userPreferences) {
            userDefaults.set(preferencesData, forKey: Keys.userPreferences)
        }
    }
    
    /// 앱 실행 횟수 증가
    private func incrementAppLaunchCount() {
        appLaunchCount += 1
        userDefaults.set(appLaunchCount, forKey: Keys.appLaunchCount)
        
        // 현재 앱 버전 저장
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            lastAppVersion = version
            userDefaults.set(version, forKey: Keys.lastAppVersion)
        }
    }
}

// MARK: - 사용자 환경설정 모델
struct UserPreferences: Codable {
    var themeMode: ThemeMode = .system
    var notificationsEnabled: Bool = true
    var soundEnabled: Bool = true
    var language: String = "ko"
    var distanceUnit: DistanceUnit = .kilometer
    var autoStartRunning: Bool = false
    
    enum ThemeMode: String, Codable, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "라이트"
            case .dark: return "다크"
            case .system: return "시스템"
            }
        }
    }
    
    enum DistanceUnit: String, Codable, CaseIterable {
        case kilometer = "km"
        case mile = "mile"
        
        var displayName: String {
            switch self {
            case .kilometer: return "킬로미터"
            case .mile: return "마일"
            }
        }
    }
}

// MARK: - Keychain Manager
class KeychainManager {
    
    func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

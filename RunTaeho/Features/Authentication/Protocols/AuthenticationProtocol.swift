protocol AuthenticationProtocol {
    func signIn() async throws -> UserAuthData
    func signOut() throws
}

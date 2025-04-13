protocol AuthenticationProtocol {
    func signIn() async throws -> UserData
    func signOut() throws
}
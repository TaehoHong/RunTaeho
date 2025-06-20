//
//  UserDataDto.swift
//  RunTaeho
//
//  Created by Hong Taeho on 6/16/25.
//

import Foundation

struct UserDataDto: Codable {
    let id: Int
    let name: String
    let authorityType: String
    let totalPoint: Int
    let userAccounts: [UserAccountDataDto]
    let equippedItems: [EquippedItemDataDto]
    
    
    public func toUser() -> User {
        
        let userAccountDict: [AuthProvider: UserAccountDataDto] = Dictionary(uniqueKeysWithValues: userAccounts.map { ($0.accountType, $0) })
        
        let accounts = AuthProvider.allCases.map { userAccountDict[$0]?.toUserAccount() ?? UserAccount(provider: $0) }
        
        return User(
            id: self.id,
            nickname: self.name,
            userAccounts: accounts
        )
    }
    
    public func getEquippedItems() -> [ItemType: AvatarItem] {
        
        return Dictionary(uniqueKeysWithValues: equippedItems.map { item in
            (ItemType.getItemType(item.itemTypeId), item.toAvatarItem())
        })
    }
}



struct UserAccountDataDto: Codable {
    let id: Int
    let email: String
    let accountType: AuthProvider
    
    public func toUserAccount() -> UserAccount {
        return UserAccount(
            id: self.id,
            provider: self.accountType,
            isConnected: true,
            connectedAt: nil,
            email: self.email
        )
    }
}

struct EquippedItemDataDto: Codable {
    let id: Int
    let name: String
    let itemTypeId: Int
    let filePath: String
    
    public func toAvatarItem() -> AvatarItem {
        return AvatarItem(
            id: self.id,
            name: self.name,
            itemType: .getItemType(self.itemTypeId),
            filePath: self.filePath,
            status: .EQUIPPED,
            price: nil
        )
    }
}

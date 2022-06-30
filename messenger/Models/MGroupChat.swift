//
//  MGroupChat.swift
//  messenger
//
//  Created by Администратор on 30.05.2022.
//

import UIKit
import RealmSwift

 class MGroupChat: Object {
    
     @Persisted(primaryKey: true) var id = UUID().uuidString
     @Persisted var avatarImage: Data?
     @Persisted var nameGroup: String = ""
     @Persisted var users = List<MUser>()
     @Persisted var userAdmin: MUser?
     @Persisted var lastMessageContent: String = ""
     @Persisted var messages = List<MMessage>()
    
    override static func primaryKey() -> String? {
        return "id"
      }
    
     convenience init(nameGroup: String, user: MUser, lastMessageContent: String) {
        self.init()
        self.id = UUID().uuidString
        self.nameGroup = nameGroup
        self.users.append(user)
        self.lastMessageContent = lastMessageContent
    }
     
     convenience init(nameGroup: String, avatar: Data?, adminUser: MUser, lastMessageContent: String) {
        self.init()
        self.id = UUID().uuidString
        self.avatarImage = avatar
        self.nameGroup = nameGroup
        self.userAdmin = adminUser
        self.users.append(adminUser)
        self.lastMessageContent = lastMessageContent
    }
    
    static func == (lhs: MGroupChat, rhs: MGroupChat) -> Bool {
        return lhs.id == rhs.id
    }
  }


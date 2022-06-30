//
//  MChat.swift
//  messenger
//
//  Created by Администратор on 06.03.2022.
//

import UIKit
import RealmSwift

 class MChat: Object {
    
     @Persisted(primaryKey: true) var id = UUID().uuidString
     @Persisted var user: MUser?
     @Persisted var lastMessageContent: String = ""
     @Persisted var messages = List<MMessage>()
    
    override static func primaryKey() -> String? {
        return "id"
      }
    
     convenience init(user: MUser, lastMessageContent: String) {
        self.init()
        self.id = UUID().uuidString
        self.user = user
        self.lastMessageContent = lastMessageContent
    }
    
    static func == (lhs: MChat, rhs: MChat) -> Bool {
        return lhs.id == rhs.id
    }
  }


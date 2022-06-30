//
//  MUser.swift
//  messenger
//
//  Created by Администратор on 06.03.2022.
//

import UIKit
import Realm
import RealmSwift

class MUser: Object, ObjectKeyIdentifiable {
    
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var username: String = ""
    @Persisted var email: String = ""
    @Persisted var avatarImage: Data?
    @Persisted var password: String = ""
    @Persisted var chats = List<MChat>()
    @Persisted var groupChats = List<MGroupChat>()
    
    override static func primaryKey() -> String? {
        return "id"
      }
    
    convenience init(username: String, email: String, avatarImage: Data?, password: String) {
        self.init()
        self.id = UUID().uuidString
        self.username = username
        self.email = email
        self.avatarImage = avatarImage
        self.password = password
    }
    
    static func == (lhs: MUser, rhs: MUser) -> Bool {
        return lhs.id == rhs.id
    }
    
    func contains(filter: String?) -> Bool {
        guard let filter = filter else { return true }
        if filter.isEmpty { return true }
        let lowercasedFilter = filter.lowercased()
        return username.lowercased().contains(lowercasedFilter)
    }
}

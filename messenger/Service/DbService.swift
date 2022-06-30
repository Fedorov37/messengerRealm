//
//  DbService.swift
//  messenger
//
//  Created by Администратор on 15.03.2022.
//

import UIKit
import Realm
import RealmSwift


class DbService {
    
    static let shared = DbService()
    
    var db : Realm!
    
    private var usersRef: Results<MUser> {
        return db.objects(MUser.self)
    }
    
    private var chatsRef: Results<MChat> {
        return db.objects(MChat.self)
    }
    
    private var groupChatsRef: Results<MGroupChat> {
        return db.objects(MGroupChat.self)
    }

    var currentUser: MUser!
    
    private func getDB() -> Realm {
           
        var config = Realm.Configuration.defaultConfiguration
        config.fileURL!.deleteLastPathComponent()
        config.fileURL!.appendPathComponent("messengerdb")
        config.fileURL!.appendPathExtension("realm")
        config.readOnly = true
        let realm = try! Realm(configuration: config)
            return realm
        }
    
    func getUser(email: String, password: String, completion: @escaping (Result<MUser, Error>) -> Void) {
    
        if email == "" || password == ""{
            completion(.failure(AuthError.notFilled))
            return
        }
        
        self.db = try! Realm()
        
        let muser = usersRef.where {
            ($0.email == email) && ($0.password == password)
        }
        
        if muser.first != nil{
            //print(muser.first?.username)
            self.currentUser = muser.first
            completion(.success(muser.first!))
        }else{
            completion(.failure(AuthError.unknownError))
            return
        }
    }
    
    func saveUser(email: String, username: String, avatarImage: UIImage, password: String, completion: @escaping (Result<MUser, Error>) -> Void) {
        
        self.db = try! Realm()
        
        let imageData = avatarImage.jpeg(.highest)
        
        let muser = MUser(username: username, email: email, avatarImage: imageData, password: password)
        
        try! db.write {
            db.add(muser)
        }
        
        self.currentUser = muser
        completion(.success(muser))
    }
    
    func allUsers()-> [MUser]{
        let users = usersRef.where {
            $0.id != currentUser.id
        }
        return Array(users)
    }
    
    func allGroupChats()-> [MGroupChat]{
        let groupChats = groupChatsRef
        return Array(groupChats)
    }
    
    func saveChat(chat: MChat){
        try! db.write {
            db.add(chat)
        }
    }
    
    func allMessageChat(chat: MChat)-> [MMessage]{
        let messages = chat.messages
        return Array(messages)
    }
    
    func allMessageGroupChat(chat: MGroupChat)-> [MMessage]{
        let messages = chat.messages
        return Array(messages)
    }
    
    func sendMessage(chat: MChat, message: MMessage) {
        var frendChat = chat.user?.chats.first(where: {$0.user == currentUser})
        let myChat = currentUser.chats.first(where: {$0.user == chat.user})
        
        if frendChat == nil {
            frendChat = MChat(user: currentUser, lastMessageContent: message.content)
            try! db.write{
                db.add(frendChat!)
                chat.user?.chats.append(frendChat!)
            }
        }
        if myChat == nil {
            try! db.write{
                db.add(chat)
                currentUser.chats.append(chat)
            }
        }
        
        try! db.write{
            frendChat?.messages.append(message)
            frendChat?.lastMessageContent = message.content
            chat.messages.append(message)
            chat.lastMessageContent = message.content
        }
        
    }
    
    func createGroup(chat: MGroupChat){
        try! db.write{
            db.add(chat)
            currentUser.groupChats.append(chat)
        }
        
    }
    func addGroup(chat: MGroupChat){
        try! db.write {
            chat.users.append(currentUser)
            currentUser.groupChats.append(chat)
        }
    }
    
    func sendMessageGroup(chat: MGroupChat, message: MMessage) {
        
        try! db.write{
            chat.messages.append(message)
            chat.lastMessageContent = message.content
        }
        
    }
    
    func editMessage(message: MMessage, text: String) {
        try! db.write {
            message.content = text
        }
    }
    
    func deleteMessage(message: MMessage) {
        try! db.write {
            db.delete(message)
        }
    }
    
    func deleteChat(chat: MChat){
        let frendChat = chat.user?.chats.first(where: {$0.user == currentUser})
        if frendChat != nil {
            try! db.write{
                db.delete(frendChat!)
            }
        }
        try! db.write {
            db.delete(chat.messages)
            db.delete(chat)
        }
    }
    
    func deleteGroupChat(chat: MGroupChat, user: MUser, index: Int){

        try! db.write {
            let indexUser = chat.users.index(of: user)
            chat.users.remove(at: indexUser!)
            user.groupChats.remove(at: index)
        }
    }
}

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }

    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
}



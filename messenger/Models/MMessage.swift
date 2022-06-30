//
//  MMessage.swift
//  messenger
//
//  Created by Администратор on 06.03.2022.
//

//import Foundation
import UIKit
import RealmSwift
import MessageKit
import CoreLocation
import AVFoundation

class MMessage: Object,ObjectKeyIdentifiable {
    
    @Persisted var user: MUser?
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var content = ""
    @Persisted var sentDate = Date()
    @Persisted var mediaItem: Data?
    @Persisted var audioItem = ""
    @Persisted var audioDuration: Float?
    /*@Persisted var locationItem = Data()*/
    
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var messageId: String {
        return id
    }
    
    var kind: MessageKind {
        if mediaItem != nil {
            return .photo(ImageMediaItem(image: UIImage(data: mediaItem!)!))
        }else if !audioItem.isEmpty {
            return .audio(MAudioItem(url: URL(fileURLWithPath: audioItem), audioDuration: audioDuration!))
        }
        else {
            return .text(content)
        }
    }
    
    convenience init(user: MUser, content: String) {
        self.init()
        self.id = UUID().uuidString
        self.content = content
        self.user = user
        self.sentDate = Date()
    }
    
    convenience init(user: MUser, image: UIImage) {
        let mediaItem = image.jpeg(.highest)
        self.init()
        self.id = UUID().uuidString
        self.mediaItem = mediaItem
        self.content = "Фотография"
        self.user = user
        self.sentDate = Date()
    }
    
    convenience init(user: MUser, audioURL: String, audioDuration: Float) {
        self.init()
        self.id = UUID().uuidString
        self.audioItem = audioURL
        self.audioDuration = audioDuration
        self.content = "Аудиозапись"
        self.user = user
        self.sentDate = Date()
    }
    
    static func == (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.messageId == rhs.messageId
    }
}

extension MMessage: Comparable {
    static func < (lhs: MMessage, rhs: MMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

extension MMessage: MessageType {
    
    var sender: SenderType{
        return Sender(senderId: user!.id, displayName: user!.username)
    }
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class CoordinateItem: LocationItem {
    
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
    
}

private struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(imageURL: URL) {
        self.url = imageURL
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage(imageLiteralResourceName: "image_message_placeholder")
    }
}

private struct MAudioItem: AudioItem {
    
    var url: URL
    var size: CGSize
    var duration: Float
    
    init(url: URL, audioDuration: Float) {
        self.url = url
        self.size = CGSize(width: 160, height: 35)
        self.duration = audioDuration
    }
    
}

private struct MContactItem: ContactItem {
    
    var displayName: String
    var initials: String
    var phoneNumbers: [String]
    var emails: [String]
    
    init(name: String, initials: String, phoneNumbers: [String] = [], emails: [String] = []) {
        self.displayName = name
        self.initials = initials
        self.phoneNumbers = phoneNumbers
        self.emails = emails
    }
    
}


func fileToData(path: String) -> Data {
    return FileManager.default.contents(atPath: path)!
}
